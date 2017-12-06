ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
export FABRIC_VERSION=hlfv11
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv1/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� xY(Z �=�r��r�Mr�A�IJ��e������6I HQ^9o-��HJ�d�x����4.�(E��	�*?���?�!ߑ�kz�U�(���U��gzzz.��=�CV-�I�f�ږCBmw���p�e<� b1����%a�/��(?��(	���'Ƥ��	w����9.�z���Tw�ǛV��Sb;�e��i��b��q�8�`O�k���t�n���[d�_�*��CY��&�A�ubGz�C[���-�u|���ʪ�*����p&q;��d�URÞ�����%���^�Q>��מ��"�p�ֵP������n��yT��q�Z���EYT�GH�sN&���	��lW���eUa�1kl����_�$XQ�*RT�b��q9���s�'��Tt3R�N�s,��◟"���Tu��Z�|�TK�K;��T���G�x��O�ݩ§�G��Ub�fYh��L�*�t9�����B����0A�5�`��b�Ֆn���M	�N�%!���������,��a��oc�	�|�ı�;��������"�&�` (2�� [X��<��C��2ί!��f�_������a!,�~q�8���ݠj�mb�+s�k!:�.��
!ߦD�bX@5�F�1�v��.����ڞM/u��۶~
gPwm��"�@��ZvJ/؅�B����vP��-i�n�Y�D���UՊL��r-�p´=4�da�mX6�� RA�?C׈鰾U�	Ia��j�nǲ�Խ�Y��eŰ������+q,ã�PF>0J�$;��V<ݨ���5�SⰁ{F�B�OM7
��5B@����N�61���t2D�bRJ��a��-��u�J���zU��AMb���Z@ퟻ\��p��F�Efu���R�O�%A��ej�������a��{����j��Q��vQS7��*�I�:%PH�홦n�A��7r\���w�q�����*�B���Чg�^C�5�+���u����KJ�A����-������~x�~�^�l؈��=0>e��C��h�x�w��ދt���oӭ�B� 
�h��t��	��g�EI��!@�?c>
�����ϣ�6�q��M��!�}Y8��}�;���<5-���L:���������BhklY��e24��4}s���Kk{7V��}@.
��<�e�(�U>v�L���햢���A�C�C����е��a�^!��?:�O��D?!6لf��\0�<����&�M�l�w��qz	L�5��2�	�Z�w����K�*��7_� ���G������5�#g��k\�2��d~�0������~)|��oL�G��<`q��a������"������ �1%&Q����o'��0�u��9�+�	���l��9j�nظ��h�mS�4����.��׿@�p��\�c)U����D�f�k`��`e�b�r���l��9�Y5Y̥>d���N�����jl��;�3� ��Z���Q;y�?��Kh��:T�!����XY�f��r��RY-�?�s���~�z�G�&�.*�C`��γ+Ci�.*��Yh���?�B�ϗWh0�{��Z����ѲMЇ��0��ZV�P,q�L�U!6�^�$�dV)i[:'S:>�#���&��w�GܢE��m(��.;~�5�0�k�=On׶��,��4�O��������󁻷��W�䷰Sά��ۉJq��᠀�*��V�
aQ	޸�M�E��!����ݻt ��T��������ܽ�sO���{b�[H7aA�B�j���@��`p�/�Ιa���L������q!]����?sqf�����B<*Ƥ��b����v�gy0��G����"҇����s���o���	N����ضe�@m[7�  �ja��9ꂇ�)=�Kc],�~�l©�����;�C�_o�&
�=�-5<������Kz�Ek����9F�=�(0"������A���*�jc%�q�pfn�LY���4K�͑r	��nAC�1������p�4M¢�`1O*Ѐ�(�M�0�:6���C���#ͪ4j���X�j?xG`���<9�� �6sa������G!������>	q1���[��y�����#՚s���^�"�⺯K1�����_���^:m=���6!�; BbX���5�Y�1O?��e�o��Y�֨VF�ܼ����Y�L���,���Y����L��@��'���?��hM?��O��M��¡�!0��q� ���2�5��A�U?�m("կ�z��N��a�rT�.K��ʳ u����-�L�'$%��VJ�mw_���}u�o�����t�
���}�
����Q�f��3!{Ɲ���X~zu`�XÚ����|�ҸY��QB��TI�M�����+�o@�	2Bu,�]��ӻ|�q�����d�+q[mj��&��*Ⴄ�޻?��b4��0Ѕ�lz�?���w���E"̢nX���G��C@C�4�}�i�x�1�J�aˮ�ar�[m�P���hѣb�� ���mg�O�H��m��zc�7!� S74��}���50L/ToU{EF�i�Ҵ~�/���Zo�s�&*�%k�q��܁Z�|���_�� �]�:"5��� 4���c�������C����Tc�&G""�2���c����W��jm5Aj�\Y��%QQ��V��EeA��j'*b��e%��ir�L�<��n�}R�V�ۤ���'2@�������k���P��$���V����T4GQ}e�B��R�Bހ
iT[��j�d��F�e�0��R��bj��3�W��2ƙ�b��Z�2	|��j$H��>g�WF	�л��&U���&���_ok�͒:��S�����(F���"/�?�����|.�m����@�	��{b�%w�W��	Tp�a��y�ߗ%M}�c��0z�/��������x��s��y"��ݷf��������A=x?����%z��5F�Vإ��5T9�=AP���F��*��Nnoh(�5�_{�?�r�n֮qɾ��5���1�o��F�����N>s9yG�w������w�el��I���j?Vv݃}vK N�I�}p��ᾠ����?b\R���^����S�=��]���EP�Ҙ��(���_���~�}�>�����������/��;~~M�A�e)�Z�DM��V���j"�U4X��,9&'*���a9�$b%��H�UEY���?}ύ^R����k��6��1"K��ܟ��m�я���Lǲ]�k-����sK�lP��~����F���w?|7������5���OK�ß-q����8yh��j;K������_0�S$4�t'(������_{�}�|�g�g�q������( ,��<�׿�z�>���_Q�K�,Ř��s������+ʿ���^�����ۖA�-�F&^�������⡖�Po�ף%��/��.x/��z�9>nPf�@z��?��!
��F��hL#�ͥ�r���7�\j�$�R�T]��j=WTގyPxޭF�]�m\�2Mc���嶬�����܎v��
jsC�3�F>up�?˜��d�p �ʩf�Q�0Z��fβ'�_���P�'7ޛZ+�I����z�QV��V9����g�㷍F�m�9.)'I8�L���ɗ3R����nM��l6�B��u
'9)_�	;�tH�NX��+{o�$+�=���;J��md:o��3�<L]*��ړ�><>�ZJ���9�'�������})��2�ݣC��-�T�3�|R`j�s�wXt��\���b����m�ۭ�i��<��L�7��O���P뙍T*���l�BNMnx�[g�=q�yV*����x�~�ux���4��a��&�in7�Fq�v��ԭ,��t]�Ǐ���Nz�P��|u�;�3ݍzg�\Nn�U����;�d��G�x��V�t�7���Z[ͨ'��O9tT�\g��Om��d�>�^<�K&ޛvq���j}j�@rxg�R�X^��(��˽�j�G+�R�����r{)��ڋ�7S���J��ȫ�<�&"��y<�SH�<��$NS�H=W/)[1�UxӭZY+�ƙ\'��{���ۃ��.�nJN�O�������d[>SHO���2	G^o[f}[7���c��?;���
��6�o�����=�3=�o[�{޴��(|��?���ov��c_�������?�/

`��s.0d'�h+s�Js���&���MgtrC�`jC���!���NnYz$�7+����z �ķ��qh�F6M���֞)y0�R�Z�OS��~����7ϳ8~~ �R���B�9�����+*]%ke�`S���ơ�oY^yG"��Hz��n�7�i�d�a�S����wu`_{ֿ���S�{JS��~��%����7�Iܬn7�����$q��Hܬ.7����� q��Gܬ�7�w���q�|#�Z���~��|��S��<��^�k}���O���-������~r;�v���N�s��u)u�o��=-�WW38ޱ3��>.g����^�ɛzﶢ�9k'{��73D��o��l1Ѱ,�:h�[[��s�t[�����s&$6�f���i���>���s��g��|����	w�-~%z��������?E���<A)�ݵY^|.����0Ri�����j�{B��w�oC���ބ�X^M'����b�� ��;~�]wxBiR�M�e�Z5��;xʅZ��u�T2�ZE�Ue_nq�,�C��n�SzA�@;�
��= ��ZX7��P~-+��)E��&[�!��ET!��a)�Tհ7nC�/uO�0V?F�i9�����޹����w1�l��-����o]���[Gv�xz�}o�{��o�G���`_u��%b��u9��n�"2��hf:}΀��g���ڳپ
#��^����6ٗ)�o[-�>��4�:l���~���m�.�_��hg��ui�{��n�BpT�@ޞ�IBO�䓧�{��L��?ؠ(��`�	~�.zx�N
��2���t��l<c���o�ão��3h��c�U�D�Oph�TƗ��	Ǟ��WG%�62c7q����{�ױ��{��p7=���f0������N�O1O;v��|�J%,Jv�8�8q*v�$�C�B���i@�A�f;$f�����A,X �Xýן8����{U�Ҕ�^*�������{�=�ɓG����O��^ċM#�km�~0�3ɘ�"��1��h�$�H���:?�'�5��6S�ţC��ݜ��i�4}�N���wA�9w>ܮ�g�%S07�2��kU=��`<Wc�ȍ�$�<[�$K�sҗ7�\|
�9�T;�Y�E[g $�!tN�tiR���^�A7W��!�����Tb�� |�ս��떊AƓ5�#�!�]ۜ�X�%l��*�IB�#T��O]�n�_1�|5R�9�Q����u3 ��庮��ɞL��D*�s��5,���ވ���*5��S8 ��t����
�h�U\6���c�n$+X��iU����!�,�k�r G@E	�a���<���i:r/rC�#��8ܝ�}�[	�n8��8$�Hp�*r���	���iz������ȩi��b7�qC�lťn���c �%EAv���P�Pw7&�E���h�Hh��aza���D<�y�#I����ʃ�>���/�?��̟���4����_'����_�G��>�����w���_#�'���{��~k��{/?xm�'�����r'�+�|'����*ŤD\I%S*���)Y�5I%c2��P�n��T*�$I��t�T��Eʑ�w?���b��ӟ�i�����g6w*�S?~����İ��"�������[V�oގ|��m,"��V�oyA~���u��ШF��~�������g����]p^�����?��E��O��{�Q�T�:i:K0�v��T��K�0Kxt�]���?:�Bg��麅�Bm��1��=_�b�������sb��&���\8�Q�IGi7��aBA�g�t�=\o��q(
u��ܮ�3fۭ��3�,���m'G�w�!DЅ�V��<��P89e8���w^&�-��i���B�q���bܼ|�nP�3^a��H"�f��``��˃�*��~���e;�i{lK����ذզs�b�U/�d����ʳq���|����T�	����f�cU�V�24�{-?�4:/���vcr����,����֗�����մ�d�)��
��ME�T:b�"���DrV��E�=����Ħ�[ �4�e����<����i���3i�Z��fr���YK���Ai�e����mRIi�j4�:����XN���=��cU�ZOHZ��g�t)5�������0ob�6
4y~R��?^J(���@�p�#��g��%�,�;1��-Ί�K;+�-%?_bP�<���`�Ph_[�`P�\O���� ����wbr�z����Q���&��X=�*N�s�,�u�r��S����,�Y�73�9Pd��H�H�XLo��D�)%:u�P2գ	A�cǔzT-y���|��,�'�1��^��$b�ir���BZF�P�蓥CtS
�t��کs��)хY"S!�)��$Ub��4ʩXL�ur�vK��*n�5���Q)E�X�\�*����f�Y�t���Ro��e��tr�]@e���hp���ȯ�y'�y�}e���ۻ����n�^��o�j%��������e�"z
5���|yc�k���މz���yMԃtދ�_��쀶�y%�RЀ�E���Z���;��:���~��z?���?����q)++-+S�������"Z:SeZ�2��%�^��̗�-�s,��e~�ܤ���s�9$yĹ��h��>�®�5�9沮��i�r�M|$0M�W �k(TQZ"-2Z�<��8����F��,�\!5Mf��=v\Us'5,��&Z�%3$ʕa��ۅ=}�v�~7Ig��ڵ�yǞw��G�\Q��q��$�v$��ˤ��GbYj�� ��0Z���i����F�!3-D�,���j:�e$�[u��j:������{��-��S�����k��ͷK� [�Z�@�G�~�.գ�L���pxH�D�(�U���(9Z�����ŀ�	r�Ǭ�#�}f����י�J-����vy�hD'>�\���ΥD����(ʵv1���aM��J\�T��i��<#��/\�7���iSA�-�C_Af��/�����+rq�m/�'ܢ�e�i���i��	W���.���!��n{��_n ��i-5�����b|y�ؖ��U�&�R�l�-qZ>찵Ѩ��KѽAK�5�jk��	���T��ԇ�W�5�J��z�d��d�}Z.��E���@;��̹�rV�i��%�&[sx��Zù@�Z���\a>ӌ�t/���5���0�i��Z6_Έ� X��}Z��ݣtU�w�b�5�ʘ+6R�"��{�3�N;W���" ��|!�d:ϥ�^w�pl����b���b�F������t⿺�&�"$�� ʳam<:�SS��0%�/Ņ3Z�#��+HL'O{�d���G����w�0����l�_(L$��I��@��k��J�8�ך�݃�x�J�*�U��5�2.���E�Zdz֩5x��{☐:�h��c��r�h6��~>n,�ә����	�(�(�/Q��T��O�{L�t�t$��[#��g�B��;Q�y��`)!�����F�!�D����)A)�-�#�GG�y����AR*a6��
�ћQ�q�vl*eG`�s���u�(�0b��me֨pS���Wz�G�o�AH/}3�FXu
���x�2��|�B��k�}O���=��S�Ȏ����c�wsՑ5���X�܋���j��d��~���n��/��[��w�{O�>%�}��|{�]Gy�7#�b��+�>�`_g�ơd��C�y� ]ћХ^��q� �W���>�hC3������2�~>�~���l�+�@G��	����׃�<vϛZQ&�e�V��<���l��G�ȣ�k�/eTv���w��<�8���D��j�����/������������f��4z�?�~�\O{������𚥛���BF���(❂�Afx�,�:LA�$Ki���]���q�]S�	�i�j_t��Y��6!J�xl�=f�O�q�nw� �o{��{úV�Z��p�eq4���v{���c��"g[ς��ƠVϐ3 銘�-���Ro�-�p�Є�^{x@Co
��I��z;Ö��A�g �zX2p�1�|t-�M��~��B]@Тg-FW���o�o���.�4ƈOQ�#dㅲx�Np��q�oN�@f�NA�.���_���%Om� �/@�+k5d[e�&!K85�l!��p�ͅ-O�7�`�P������mc�[W�>ҐQ�L5�12VG3}b����̚�>l\�B�#5"�pC&~�
�y6 2�A���>�m[kr#}�%��u��`���N ������1���"�l��	7(��:�I`
T�E`��y]1�V'����%c�� ��	W�V��_��������K�
q��<����eu��^;���_�����ۦ"�>���$t�dbZ����/��-��<�����lS��4�Zs�Y��`�*�7�����Đ`	84$un�As-��Q/bg�7NՄ���'��I.+���Х�Ƴ3GP�`6A�(��Ȓ�b�[0�i�+Y�@��+��f���)�<����q����q����*�Rɿ}���}Ꙥ�eP�5ޅ��Ȧww ��kv�U�� ��uK�%<��[x��E�����WB+O�t@2l�#�aC*�2,����B�q�Z�7R��5�'�am_A�Q0hQB4�+�ƚD��������>��U ����t�φZ���4���Fȱpm��y
d;��Y�`�ݱ����+�\0���ay�:�%tKY5qհG+�Uj�*Τq�	����/x�e�y���oN��@���6�.�kA�{5"Kt���hB�ր�5�-������?�F� ��~�ffb�x F1�@�Q\v_ G����
*WDnE���(��ȴ�u��6M��G1�����2�S�/�y���D�_t�9��4oAi�P&BS��c������#�v������g�b $�nGH!�y;� �B�?ض"������~[�?ϼ�w6�٥u\r��J���T<u���V/d�>�!�!�Aл�V�%��+Q0��+D��C��=�����q�>���GU��
���-\����oe���X콋J�ó_�B�U�y^/��k?[=I*R/N%eR�d*�!U���q��L��]�G(�!I��3�"��^&)%iU"���������]a���ҼXn@+���n���x� 9ytC�^�[&$0�@]<H"#�IJ�e9�H�R�����Ƥ�$I�d"��b�dZ�K�CIq0�錚H����T00�Cٍ���>��Pq�[π�6TC����cw���U{�M���ؽ'��A�m낭�d��b�W#�J��� ��\��ӥ�R%_���cE�������ȕi��s���Үb��|C��B�}���/ɺ�����s.�]Щ,]U�}��,7�tx�	0L�7�h_����Ȏ�;5�vT3�ZԚt��n��2¥�s�N����-����qb��}M��Z����v~���<�p����o� َ�l�������=[�s��|9\������͗�v�ӥ	�c������1Wf��,>����~4����3i�LG�n��
�'*	+?y��Q8�Om�&�Z�l[����JC�V�9>\��V�~ ��=���8|iw��5�q7$�f�.�*-��lp@,�I��<(�a8r���"���q֜v�,sA�l��-���'�?@]X\���L:�B	4���Q���=tg�qO2,�&�'	ƛDA'�#� ���q����
���F�#�v�ߘ�k֋��lg+����cu�Xǫ���[m�;% 3�c����]�n|�gc�!���p;b��f����
E�*�*:��~������Z0�Ȼ<�A&d"I&��^������9��,�n�����	���������?ã�3�q2�����x���)���؝���xn��m��J�	}���s�������[y�
��$b����������s[�}�$�e���s[����_:����w��o��@s�����@�e��3=_	�����N�����;Qt���+�{�j�����aRAp��,fqBE���&�����R�+Ͼ��J�Z1����[	��a��W�(�F`W� 14�"�����9����fQ6"|�b�!��C��*
\��G}:?7���	��$��U�o����$����EԚ%�<٦k�}���Ċ������Cb4���yr�ݗ۟�N[k��h,{ن����Dmm"���A��e�NY;Yb��c9��Ճٟ/�d|X�{�@��4s���ص�������:�?M8���_>���gC�~��Ǩ������cP��M�}P�'���@U��7��u��O��������G1����o��u��������?���@�W����*�m�D����v���{�����@���)G�0%Z��������=�����pU'\�	Wu��G8
��؃�O������6�������O�� �W��?�ր&�
����	��U�5�o����s�S�{��ڭ|��z!�-�B���,k���5!}���n�����~޾�h=�ݻ���O�}��E�}��UB����>_�>���c�\���*k)�ڿ�`�_��Lv�����]�be�/[ڭ�u��aߘ�{���,�NG?�ؾ8�ݱM_�Z���}��}"?���u����万������~�8}�X�$}2�Yz̷�h�ۓ��)^���^��ܕc-G����V2��C+ޑb�ҼT�XT���oS�{��v>�[�?�<����AUv�%#F����l�nE�F�?��׆迧Q(����[�5����_����U5���?�p�w%��'���'����?�8�*� ��%1������[�5���?�
��
4�����D�?��ׇW���������[�b������NF��Z�q����������b�g:�h���z���hԳwLK�{�Y���4�k-�{��o�]��Z��ӊ����
r�J\`b�I�vߛ�9�o��fw;�u]��'[���ׇ��O�^~�	5�/�gK�D�PR�/m|䥏��6�y��cCY�*��GT�c�Ӳ���m(��v�Xis� 脠��
�EM>�֙���k��0a�OLt�IK)�M(�xq(.�h��>7���74B�a���
4@���K���� ����_��������J�$�"c������b)�d)��8/DC�c=��Y�'h¥'<%|ڧ����;~M��G����������ʁ�.ω��ڝ�N#Y���Cɝw�k����h�}�u�/�����D�'O^'��ɪ}wGL�u��b�V���8��t����)�b9�${0BG�0�];��n~܎ϊ� ���h��������?_C׷V4���W��0�S�����WX���	���W~��;�lU�u�Nc&6��3�h~���jp����q�>e�Yz|�򀠇�D�G�q�KF�����D�^ Qa&�(�]��8���J��l]օЋ�-˜n
����ԐyT%ۖ�P��ފf��8�kB����?�����M������ �_���_������@ցF�?�����
������b�k��(&�Ȼ�q3cg	��<��������|���َ3䪶?s ��͟� �V�>��*U��d�/��J�]�� �q�Rrl�|�5�SB-�-�BW�!BF�N[P��2�l��)��b��XO�:���Pz����x.8�ތÒ���f;~�Ď�@�M�//����z�� ��
M������*>~�������q<
��i"H����
����gC�f:i��&����Є���
kg��5."����o�yM6DE���z8�:m68�K_h��jOH�y$)�-���~?!w�r8�ar��L��E$h~�oR�GN�6e��,�X{zYY}u��^4h�������W>���]��h.�x��������w���x4��q�A���+A%��~�EU������������C�?��C���O��ׄJ�ƹM���$�2�`xH��˹�K�$2(K�!�z��6����B�	1�vCX��04��?��E��S	~���3�R���|�p,��Lx�,������u�L*�2�k�%o�����4Kr��[���}�=��1���p�l��l����n��	��6�9��Ǟf�87�D�t:�a�����M8�1���?P��������_%��P��O�� ��_���]���*B5���2ޛ����������W*������T��?��NbP���������u�[?��u	�B��Θ$�Wk�n��/k���x�e�[���3�߷�!?3�}ke#�8�]Sc:��)�?�T���w�Ȫg�����ii�tpb�Y2W�K*��2[}����f=�����j��$�4�a�]!���(��ƴCʗn\�K�Ov�[/Wz�z�=�^,�a�[�����!��`U���nc����T��Z���������d[T��T�FD9�{�<$Y��)�^l�#)Thn�v1�NbЎ�ؤT:���K�vRy��J�q��Df�7r��"�s
t{�7z,�24A�]���[��p�{S��s�&�?���Z��o������W	`��a�濡�����_�Π�H������	����P9�?}	U�����A�/���������������������ǟ����K�~��Ǩ��������+A�G�{�O �W������?u���~�����B���5���v���������������?����������U����?P��P	 �� ��_=��Sh�����0�Q��`3�F�������O�� �W��?��Ԁ&��G�$�?T�����������I�A8D� ����_#�����Y��U���A�	�� � �� ��^��@�A�c%h��˒�����ϭ���ϟ���?��^	��0�_9���a��>��?��������������W��V�%��C��������	�O|�Y���C��îb�CC��"�gXe#�#��X�#q"$0�f�	�]�e\����\����e�	�}��'h�M���������O��/��ۻ:N����E�V0�E�b0�4is�ʣg�OP��zw�^��)�˱jl��b��"Ϗ'13l}���U�qE�UNȍ�N[^#�de_�1u�:됲'=����b����h�w}�-���@�Yh�	m�j�Wkw���~��&����Yj>��5t}kE������?�������q��u��M����W���OhԹ����ڪ;$o�P�-GA9�^��6:�~'o�/��
W�y4�z�&�-?J�����(�w��g��Q�m{~�ø[.�s�ߏ��4��(�*Gi�]�2���{+�q�����ߊЀ��w����{�o@�`��>������A��_��Ѐu�������������>��u��B?��T<�[sfd�+�F���N���߳��I;Ip�����c��%����jg��tZq{�4{��=�D��O����TOXwOit��S���^�e�s���t��bzG��xh�z�u���v���;}��{zt�m�߰;B�	���A��p��㗼���,0�]�׎�Q�wOA�X���P(7�²�>�0�I[��|^�Q�1g��s�����7�yD�J�Ods���<�Vw�rT>��, �-7pS��:o���7�Z�qO���vG1{�?���O�z���G����[��4��4~='�!p��V��x��_�����������M�� ���+�G��?%���WcQ���q�'Q��J���Q��K�W�j��9�2=������?�����B��
�V��-Q����M?m��v�0G�A�p	��Wxү���H����!��7KӢ�\q����W�F�{��-�J~�{��x)�!_k~F!�_z�E�}��Մ��t9��.o��[j	�ml���-!��TZ�k�U��6Pg���aO|Uܵ2zm�ddD���F�r]�d1�)Ξ�Tb\.[�s�<g��6%�L�׶�N]b]��S����bl1���s��}*�=U���K;w}}�����׼ď^�~��[�o��&>}&)6A{0��DK0�۲pCl�m#��=�j-C��Kd�Z�����=^d>�� 1Y��>ex�#F�)�X�lƝG�i��k�
��l�J,$v�
�<G���+4�>�F�:r["��q�)g��P�}�~/h��������[���G����D���w���1��m���%q���gH��\��h�����07D},���B���������_%����G|�ɏ�(����Np�O���]��٣G����/���r�[���G���
�����+����Ca���@�����������5U<�W�������V�����������ihe�0�]f�3:�����kU[��Η�:���j������q?�gj�����L������R�C�V�3�$7{�Pb�s�E�ߒv���4��ӓpLnPś�Z�9���i^�x����E~vH>c�i9�t�q����[�yo���<����\n�o�	oGݖ8i1L�v�=���4��b�+�Uɫ������j4�z���7�	�Z�!W��բ�(嵍l��Q��U���g�J��4����+x���v��\�=@HB�<%Y���4 $$����Wh�n��t��⮽VbZ@��>UuN9���kx��,� �jj���qZ&ӊX�w��Vd�����wB�qi�����J�RQ�l�2Z� �?�[���,S.e�,�(@L�8EHN�_�l.;�^Q��/�������9��
%z�q�V��Ҧ�E69a��+���\,4�mmh^)�����˖P� _+[`��S���?L���L&���@�N�����?P�E�(ڿ���	��������+>D���4p8(1����r�;�����#�c�?|��A�]��5*�E��h�Vժ��6<}e���?8Ϟ��W��S����u;�Z�1���$
�� G�]!Sˏ������g����������P=�\!_;tu�B�KWN����jB�0��U���^��<�rf7���9(4��.͛�&1*z�U�?η,��֫��l`�z�:�fy��U���8�S��l�M�ʚ�t��Y�3Z��5����KeklpX�Q8����X6��}��
D���M���V��Bi����*��eE�Ś�#�[�}�/�kg��:��vK4ؚ��(�lS-��j�4�u{G(w�u�2�,��&�6�v�5Y=�%��RQ��%SVS�m�������]�E����{N���H���/����D�(�"A�?������I���S|����D��!����O���ߑ ����?��O8���C��R�� 	���n�������!b�����D��g�߀���#�����o0�����K����_q?%�����r��Ġ����Y�w��3"D��g���EH �C����/������ .���~v������?����q�?�? �C����������@B�慈	Q���� ��D�����^/�����0�#ĩ�`PH����������Y�8�#"$��aDH|H������`��h �?��0��� �����Z�������[�%����lH�ü1!��Y������H �?��0��������p�'ĩ�<S���c��_��K���?��_� ���ǅD��p�l�����8���"����OL�S��ԭ�ۮ
��� ��׭���������?D�D�B8�br��P��#	���Z�PIE�&Z&K�*�Uq��M�s�C�*�Ø���G�>��I��}����������l�}��at���%V�W+r�e�S#s��"�����@
�Z-��w�޵2X^�v���D5�
��<ar���k�Q�6Wwk�֨Ķ<ꥈ��e��X�6�ϐ:�N�$�N�m��u�\��zA�i��c+3�����Y^ۊ�F77��Nټ���*�
O�`�a�������p�7	H����_|H���?�!N�?\���q���E����9�?N�kDqUh7�Az�aH�TRANQ�AP�����3+�0]������YcRotgYq�6�,,������
�����L��^��z)����7)K\��n��l����4!fEWOWyOڥ�<����d�����	q�E�Q��R�FH��/�`�����_0���@�S�Ԁ1"�����_�(�h����k��F]�݂����R}�(pF���_a������\�qG�qt 7~�ن��mc1��jv{Т0�jt��ve�:�@����lSL�#6��P�%�a�٥l'$�-�
&��em.M��ԒV��WٸMJ�L�<����A��������yv��r��pxM���B�k)�}�B0�V���<�ׂ�C� ��"��kB9Ϛ�5�}ɇ��|"�|�X�����ҵp�UT
���#$��su�X�GlP�p��(�<"�۔�.��i��Z�G�}R.�644�"&5J�m׿{�wI�8�?Ņ�����d��"�����va�G8���xy$����_��(�7����6!~@���7�ؙ��
����� ��+���?�������"A��o���5�?������0����I��2zD��_��#���( �?���0���E"�~���H���+@�
���n�����?Ć��?\�1$�����q�	��؅��]���g׍�grMn��L{HO4�,�C�F����1�#���a`�u���}�Gx1�[b?���	����;��6Nq����iq����wJ-n�J̊��r*�4�´���&9XW&�^o,0Q�R�k�͊��,��U�s���������P�M�)�ð_�k�~Oa�ȅ�_Iv�cӺ���b��Ɨ�����6?*tlc���َ� ��~Ys�ng�aQƻFo���XW2�l�����Qr��-f�@A*�Ԛܘ;���kx��,� �jj���qZ&ӊX�w��Vd����0H������!v�wo���5���[�%����lH��7a/@�H��!���#�����_0�W��?	�bB���n��U���[�%��)�LH�_8v �4�������1�?������X^�J��ٮi��r]�ֆ��j���?���S�D}�,�se�ߞ��* 9�q�]{�Bn�uɦU���󒒦�\��F�&J�:���L��ziD��v�o��6j���&�¦���ƒ�(Ӝ�U���c �0�[b �0�b ��YQT�)#'8l�uޟN�H[ed�d��2
^nm��XNn�"Gy�E���K�������TI�G�2M�dm���lX߽��H���/���E�����"�q�����_��K�g��3���@r��̑�"eM�%E�e%u��dB�0�&e�"4���9���L�(E�Z�ebB����~�g$��/��	��G��\��ˌ��IZY�:;���]�K����x�q�Q�fu��R��?���=$ҕ��RW�@�;����g�9R�Qb`8zF�����L�&���zͲon��n2(���P�4����mbӖ?��>I��0�g|�����@�]�I�������8�'6����E �wU�J$�������s�����f�̥'�O�Hi0��V�^�u�5J;\`������;��Z��K�q�<Y��,r���ZP��o;B�b�>#��nz��[�U��:e�oe����n�m��.���7I@��H��?��E1$��Q v��Hp����_0�+6��/��`�����/����A�Ee���	��A��t�N�Ušֺ���6��%f�M����c�s꿯�@N܏H�to%��_JR+ś��*k�W�l�+IVfFA���8�O9d��(�q��4��]c�i�S�����jEq��\³�T}���S���>�yH��8�J������*V�ǵz%6��"�����?�@.�8O��O뽊��-�'����������Y�*�� ���m�wa�]������\1�O��H,����E�A�@��}Nf��.�ԺSTx�_�Y�5��D�����u5;�ƺZEH�R�3O��U�^ヵP�eC���zk��m<3�a;����o؁o�+s>��7O�ُ�?F����	�&��Q�`�u�B��+�*z}4�n>5�7[iu�خ�X�-��B�c��>�i���8w���f�U�?~9��T(��x��^�+�Y���Vf����u����Ꮏ.�7$�R秢xW�����_�r�|��i[̣���_��@_Om�a+��=7��e�xd���p����I24h���������M+-K�� ?����Q�B5��|Tu]��'긦��|���dM��S}�Z]�s�*`7hFf��rU�m��^Y�����a�EW�Q�PQe�*(ob��h��"y�����[T���?`��ī7pl�����y�W��?��wW�?��:�l�R�Õބ�G'�0¶~h��� �����z}z��v1��3�r��I����P�]��uTw�Nt�E-�mtߐ�a��H�x[;Բ��8weY���s�d�mu�5=o���ro�˶��bMh���5���J�j!��/��6��K���xsUu>��݁K��Ȏ�g��*���.vc�:~ߟ��|:UE\����=�Q��VwZ���qWy�����͖m���-���7�<�5���F[�����Z��7����gg7�*����>�Rx�Փ*f����я/���D�ǿe��c�?���?��`
h�	`8�/
<�����T����L��q�p��������f�����|��G;���[�}���{�K&�f<$��+��bU��3�AqW"���x ��{}���ťyh�}��]�׮��_��t�{G�*����+��B�Up��]�蛷��DÖ�����]X��^����|u$j���U�z�yr��tnK��o�8���?�e �?�#�7�����a�o�����@}I?�9����^P�r(��M�V�9������E��}˿�o���qյ����H_u��Z�9񨦿��J1&��S��!b������5A��?<P�O5��?������_&C��3��"�}��H��L�� ��}������[��:m����[/~#��j؞�;ز~�:;���Ǎߟ~���|p��������������н���=����+����5Z�@�pz�7~P�u(޲�Eث���Ll�'=�%���0�>S��W��U��)a�ȟҔ\O�Ⱥ�jl�w�����E���^�>�������}w����P/��yn�P�M�^h|�ݕ���矏Ǆu���x�����Not���W�S�vWAa9����Xk6��T=I�KU��O�/~/�ûy����ES��A�����
K�
��OkW�/�̗�P_(Z1Teʖ��t��'���W�[�%4���#�e���T�(hKw�����-`��=�����S�A�`�^nП� ��}C��ߡ���ϟ���+����Ox���L��'�/Y���+/tG�Sp*4��g�jb�����f�y��j�+	�.3�=�v���v�A[��v�]�v��(j���v�e��叶W��BJ�*���7$"��r !��8p@7@�W���_3ӳ�F�q=������?{�N�Q����&������}rQ�ͧ��ai��T,�K�؏3t4�?8�/����y����j��Ķ-O�Ղ�>T��\P�hT9$�-,XC{��!FP ѷ�E
��k�����+�;��Op��.�����NA/�T�������OH�xh�HH��]��+d��x+�G>Ƅ�qJPd��ɂJ��9��E��Ԗ��S�JWB~�"���v4��o���m��+/�����A�G}�K�6%n��Υ;l=k ���9�����X�i�x�	P%����Ͼ�s�'�֬�W�������}�hkv�3CQ�,7Z�k4J(����T�FX�0tPR,V��E��!9ҠB���Z]���_H���<�\�D�
+*)��I�}����y	�U5CC���rc�s��k���Z}��\����a�<Q��k����bq_i�{�0X/���x�~t� ی��w��^�������s��o������8��ڱ�N�g�&+�Ӆ�-/x�S�>�,��M�;�j�C�e�t��9�H�Z�}Gܷ���wvO����ƞ��7M����^˃�%�S<�^�A�9���� �r���F�������y����r`;�=��A��6��;�~R����������������r��"�����/U������i�߶�Y�Д'�n��ɘ��k���ɛ������«�q��*@3Tȶ���n�?������	º����Y|�{E�s��������w6no�������_�qbw磏�`#�0	7J����l4%�p�F�f萬1��pL�	2��D�H�j��,��,�{��n��<�5�*?��7H@l�W������ �̾W���G�M�	/��K���[�n����ƭE9>�����.����p���.۟ ͗�C�-�⫐�+^�2MQ��'������rm��g�~�B�O�	����1�������x�#c�`6�#1*���`�䡯WDiY�0_�;�=�����3���-m[T�
��wI~ +mm��	����������|9�#�ɸ�����9�0�7YI��-t:���}S�AUϳIK��$�|G�9\C��d.�w�j �z��ɻ���2N�u�}����Y,i�D�W�9�q�H���g8mX�i�����:�dʴF}<8�<Fv�{i.ơ����nK��[Ե2o�Z�ܓ#�;�V~���h���-'�ad�Z�����v���TWWXm�[( bf��Ny��1_퐤����9ա���}>�΋�>y�=���.�)w��}R��%�v���f��hi3T��O�Q���$��0TG��;!q$�������~H��X���"yHZr���W��,�ݫ�ٷyc)���&��FN��q�7�&�y���!�������,�_t�\�����ﮌع��Ov��?~��lN~��wn!Ӷ��l�}MX?ۉl�a�Ct�6��+EI�Q!�·�PC�.#}���kc�%m{r���	���=)ƌ���Ӈ�K]Y�qHK�5�r��=or-��m���B<K�=l�i�6�!�H�_�rq%���t�̩�-�B!��C�Q%x�\���i��1r�dØ9bƓ=�9-%�iv�_�����>;W )��9)��j���B.Q+�Km����p��/�:d*����J��C�8����-;����p��>XT�s��ΊfM(ٞn�qǶ2D�Bmz��T*�1��A]���F6�Q�)�Q��k�[���Be۽�z��t4WP��B�2CՋ"x��p��0toc]�WtiOۮ ���.�z	���-?��p��1�(�iz�R8lr}�TAv��d���
�"�Jʊ����Ch�eU�v�o\S�pwOL���g��[��^��)&8���7�?/��M2����ɟF�����������?j�B����������o~�ɿ�C�O)�=
���7nݽ�yg�'x��Ut�_c�Տ>f�`8�jr@f�j�i2���"�r��DXF�ЬƆU��٦��j~`��I���W�y��G_�Y�����Os��?~������?�^]�Y�_�M|��ul��E��-g#��om��=�T��v����O����85���`:�Љ�x��� ��F�W�FF:��X�S�F�' 
;ѹT�� fc%�iz�2���"Ţ�^�NXr�>Qz�V�R�`C&K�
��B}jU�#d;��P�����-�t_*�'�$)j�X�e�#	�^	H)��M䧁C˿�l�!u����y��W�OA!-A&�C:�'\��'!�@�@S\-w�֖8�KϢ=5s��g��PgG��Qm`�Q�Q�-V��2��ȥ�bj�� �y"������DK+$d�r�)%k~79ٓ�0�AJ���ZD�w�2�6qe�#��9?�A�AlZIyd�,���G¸��G=PO�Ӷ�p��x`�2�~��1g��rl6���Jg��BK��H�`�[z���Z&f�J�6�ˌ[11y`(��'�ReT��0?4�r�x���,�BS
�[%�90G�߿P��H��%P��8���n�T493B�)t��)P1e��AŒe����Y}n��.����l�He�ζA���p�j+Y��L����b W�*J�ഀ���hi��U��K��)E��O�UȲ#�����>Z�A����&���h�Jv�Kei��LB���W��#.��b9M�3��~�(V�5y��K�jI�Y)T��x8[
����\�f��t�S.G3�$ƀ���ܦZq^rc���y	��A:qZ�J�=^���uy���3��^�h�+i�(�r�@,�I:�fS�,�%�����j-^*1�c��bB�Q�iLX�G�j���׷Bq��J�je���TKl��=��e�3�L��@ĩ	�K�`_J��>�1��D�V��y�_���+�Ow�_�K�Å�R�#���arP���hgNq�l=`c��i�C!fg���RAd{��� ŗ�=���P|W3=awl����(xe�\�s�n��ܸ(&C�q�8Jg��T68�C�j��tf�$!��j����h� ��G �WE�ITd�^�j$0�hs05�&[�.6?��?W1?���7�b|�	� R���A��&����|J)!U��v����g~2|j�Dr��Q=�m�Ӝ�ħ�~�ڊ�368J�)���L��čl�KkB2���s�z%7T�@4�r��l�z�0�Α2�����~@���-�b����������������	��s��Ɨ���r��1�\�MCWf�}ⵍ������:�s^�wJ:��/y�&�ؖW���K^��F��;��8���;Ŀ�	�������ǎ���{���{��%�م�,3G@���拣�$W��h>Z�e�P�S��)�/�_,��2M��)�AD��O"��4xQ���%@��h���9@��P�� �A}TJ�s*�
���ފ�Z�S .�T'{j�Ges��ب���^ _���
��zM������V�Y���.��?<-���� ��a�ӣ����fr+��
��y5��,^K��v�k�9������6����ܮ�z�T�����Az� ���^�2U tBZR#gV!ޤ��h_k3��U��3U��f��(%�p&������o\(41�(7<G�PK�E��+H�LFgrVk�.�O���s��)*��?s�AN��}�A���m�>O���A�,�xm���l�;�&L����6��W���ʻ+� ����4��n�j��˙p�������:��j"?��d#��ӵ�Ug���B�_Ҳ�V��*�:Ot��3ڨ>-��
.��
b���X��gy�T;�f%�Zc�5�e$�u@��ޱĚ�B�[���e4�[�j�h��$��h�H�oŒ�S0��,�Xۼ$����p^K���t��-Wԁ�.�&i6�iO>�KB�X,C�i��L8�J6���.
!���gӑP���n:@�r��������J>�_^(7�Hr�$7�Hr��\���o@ps�/}�xm�u�2ў�x�<���|�L������5k4��S1b�%��&�*������*�q��^�L��H|�+Qy��K�\#�"^� w�<yB���	��|��i��5d�u�p�^Dv~��(�����v�D�^2��¨To�~�M�V[�x�e�=��Gez��_����#��P�G��!�������:�ë�P�,�"Xb�{\�k�/dT6�K����Y������uC9�u��� ��e(ڽ�A1�3G����ߋx��]�>} ����3�5���2FS۽ʤ�'�����E��"��r�ps�+���5KBq_(�OY��� �BWߗ"=}����po٣�m���F8�O�l� h|yA.�7�/j����Up�]fW�]�H*"78Vn4&��J���,��D�P ̅���P4��4��#�(���C��0�e�Lw�����Vmx��i�{��p�\�B�����3�e�C;h䌩\g���_Cx����w&�q�90)d�"�9��a_�<R�Ƹu6�X*Y>/
�ң��w&5��$�$����!N���c�����-�ݩ��>��p�.�F׹��h;�>�B����CU�~s0�́<j����oA�g��<uz�V��\
i?!�ȁ�^�:�Y�4��õB�< ��ZO��}=��z�_O{량}y&�c�t��p��<\�� ���l,?I���*�tW5���-?���]�ߏ��y�����c-3����9=_�u��aE�I�����Gp$6L�aV(Ws�=	��+O��!m����>XCt=j�'5�Y�I��TFP6�o�/�Q�$<�!��x��X�KţN��7w�\�P6f���z�<ÊR�=Dd�U��r�E�Z�#�B�z9%�Ѭ�w��vW���5�%l#�����:���?e�8���ػ�%U�,��W��0ƴܑ3�J!�/�/��WPAQ�~ �Vz��ԩt�^�]���d�ʽ3�^��p¯�҇�Ұ��_�Qx���ͥ�w�3���qy<�G׽ND�I�>x���t> ��W�Y�:*��u��F��W��/�H~$���
�+�3��(M�<���p����&�3X����֟�D�3���'S��FF�(t��t}u� |��!�W2c�� ���,5�:��������쓊���1׶�A��}_���vT�{x^�e�>�|�����w�M�h�87����=2�/���o��lorl{_�5�k��^���A#�=��|ٕ���������7�W=ԭcJȷ�v����u&�1�$J�;?��٣�<3	_M7�|;f�9%ai�s�6����p<g�"�|�*�+��|��
���VƷ�3�Pe6��	/�42��8c{3f,#X�ю�=Qy���n���m���?�{~�V
skl���U&����O�_^��3��s�ܠ����?ha�Q�^��Uy��u��d�I�[cn/�$�+��������qW�I�����:�R�^�J�R/O�T8�"WE��d}�m��x�H`�G�wι��g�\ر(���1�9�zOr7� ;m����ݟ��Ng��I XȪ�}b�T��2M�/Q^l"�A5�Tg�/ȣC�Fǿ�Exw�e���Ë,}l�������W7������i:=~>A\��B���8�fL���2t;7V��>}}Qnb�=�mE���N&C4��RY&\*;}x5��:x9��{S�1���ՙ�}����G�R�z��xs����D��ТP_����o[�z�������i#I��13/ׯ�m��ҙ��S4QDg���cߩ�A&����)��xnc���%���c"�o���oaN�o3u4S�Q��K�u��\��$���zjn��������UA�_H:��A;��'5cd��v�)T�h�o�r��¿ep��`#=��,wmϝɷ���!Tai�>����f���E�e��o�s&�n��,U��4֋Ip��M�CrSwQi�$T��6N��y���A����;��W����Ղ��C�;��^S`���z����^�xi�����k�*f���n]=��a��[�����e��Ǚ�Pן8�4~���D����0�P��檼�Bn�}�٥?�7{�
�3r�#r�|���_۳`z�����^�ю_�x8�W/k��\T���oA>lF�ն-۽�MNu��ig�������)��Y"���D;Я96+`�#i#�ҝsb�
|V��n���G6�e���j�����i�j�g*P�&�x��k1�G���{}�ǵ���o�~x+��`�S��QG�7
�c��nLA�G�? ��? ��? �#������0������B�	 �p��p��O���4�w��p�A���~v��i辎������?�w��Ɵ h�?���#�gŶ���zU��'p���������<(���_�E���i�׶��v�[��M����]���Q�����)���i��^�?�P��q 6����m����".�e��=^�?���P RP �TҤ_�B*쿣op����b���!��n��@���1�<Hj#�ҍ���L�:��G�NP�1d��С����������K#�?Ac������zS���XF�'��T�L�{�� ��zj`6�7�>O,wb��NnS^!�n{�ʕ���IfnS#�}Ǩ�[Q7�@�isJnE����,��X�o)�Cxŝ�js_�{��d��Gjs	����3A^���ӵ�m����%P��>�K/s��ev����;<eH�����!�?��$}����c�?����� �����I��8�'�1���� ��O�������q i��ѓ������ų �?�!���@�J;�����������8�2����(�����I����?
��q���Rp�.\N۬njV���s|io?3[��w�m��>m���O�m�%v?8ܞo�D[.p��$Z������^y�W���U���%�֖�^��4�=}����Ĳ~4�9Ų^��^�T=���5]�Gq��T��Z��J_�����J�]��t�ʖ�>O�roJ�ta����'�lUf�.3ovF}U��:lM&�����+�-Fr�a�IHq_2=y�n��#�'��'�c[6�r}437�8Ep�XO�k�A�$~����xY7+3O^�����Kj��F�"�L�'�L��F���m�Gx�&��Aj�#7hD͕��d^=�T�͍�A�)H�Ѳz��n�aΔ�%������E[\���),�i!�]�\W��^ Yf;�v��k'i&�VƇT�؃�_���i��t��� ��׶�R���]��LH�C~h�H��Oa���$�������o,����'�6��;Yw�Ėʙv<�>��H�����)���~"?��|�(e�ù�A�'��O�+��5D�},�����8F��B~6s��A~��ae5�Ur�8�\���/;�ձ�),���p�b���k��3��궅���Qjvh�Bj����yJ�D~$ﳤ���fw�M�[��2x���M�ۆ�l�+}k6/W�w�>��z��w�.�WESq���S��ҡ�YsI
�P/�rec
R�y�w(Z��Z�ɕ�<�]jt��sgkYZmi��|�i��i����`�?1���Da	 ������T�?��'���?�DŌT����H��8 �O���O�������� �/���s&&��'������
���{�����@����E���:��������f�������������w���rc>������/:�����#����{E��[����_��;K&+�5|'is�7j
s�\inc�\H-W�b��V�'Z,Yo��Y��H�dz�p`ykU��#������[%�IW���n=r����y�_/s��<���Oy��I6w������߻���l6�1'��|��`����iF�Q��?�)}f�W	��+Ih	mq�����ٳ9��yĄ��J�p�+�kw���o��������8�q ����;��6�����m�/�O��a�?����#c��u�ƆT���<�R,��Ajy�����4�Ҍ���:�SKh���?�4��C���c�g��;��@��&�]�sUql'�]��r��Yb땧E�yej%!��o��Ö�%��&�7]j��rg/,7��,!�qe��=�ꍭn��E��f
�c��B�S����a�eΤ̒���;I�A���H�����!��ߝîo�H���_rH�C�ObH�+��w��4�?���3��M�!�7���Z=�1[�f��ܒ�;��Zԭ�`0թ��؛��'V�&v���0ju��O��TR�Cn����D�݀Dg&�4����n+��{|y�ɶ[��G{�^�5D��\[P�����	X�Mi��u�}�O�ܿ���_�� �� ����Kx�l��
��w�������[�����&}�����[8��,��ʮ��q׿��N��?pÓ��j:�om�� $��'� @��هg ���^���)��RE�C �<�klG6���\.[qmB>�>Cg���g�9^~�Jњ�Z�fI8�x֬6�F~��a���O�VX;���[c=e������C�A�}�3�[t����3 �"�)���yS,��p�wP�U��3ͺQ-m�|A�cw�d��bJ�|��F�jN��Ȏ"���Fc��Y�h�����=j\@����'�"6I�ʨ��,���p�t��l�/��ɤ?*H���j�%�δV�&��`sFˮ��Asswa+e�箔^�3w|�������q�N4H�����?���1���
�E����� ��!�#���q�����ǂx�4�Ҋ���G��	�������������?�����0V�hJ�4%�(3T�n�:�����4�����j�`;P%p|�g�10�VH��UH���(�� �����;�i��AZv��b<h�5��n�v��G���.y��
i7(#��m5�����V�@NےJt�*�Y��X��-'o�\Cqqܨ-z�.�rr���ܔ�Ng+�����b{]C�E�ߋ4��������1� ��m��8��#��$
��q �O߭�C�_L�����b�)�?�����w�`�Ǆ�������Ӂ���G�����x��{�������fu���0Ǘ��33��ټq����.p�)�[īc�gb��ϐ������Wc�=���5]�Gq�w���f�wi��w|+�v��ҵ+[��<�˽)�҅1�k����U���̼��U����5�P
3`K�����Q��&= �}���i��W�,!�^n���m�,�#��_���%�E���̓��e�Z��Q�H+��*������69E�RC �A#�h��v� �ꁥzlnl�LA�����x]v+s�d�(��է��.��R%Oa�My�*床N��2�a���R��`���>��%���?8�=� ��k�i�#��B����)C��G��$���o����o������~����XH#�����_����C���	� )A*��G����@��A�����z�����b��7NPj�7
x�8��#�?�,H�����I��8�?��i!a ��'��p�wRH��A"Y ��'��/������X��q�� ���8�S����X�2�q�������� �@����!?�T�؃�_���i�� 3$9������T�?u������?���?��@�!���?���?��?�I� ������_*���C���!bF*����?�� �� ��d������`�9����_��K�S�=����q ]���q#�?��'�������[��?�T����/����{ǵ�������m����	���#��ǂT�?��֠���P��h~�g��Njy�%q� 0��UT'HTW�<��ƨ*��$�����G��4�?Ac��'�+��ޔ��������/�}��{��K��k�����W��=ɱ��F#��E[سQ-�����X0�CSnX�f���5�[�it�ͥҙ���d]r!���f�ٝu��&���s��t�xib
�ձ�M����s�Bg���m�X�2������T��2�a��������a�7I�a��/9���!�'1�����ềI���C������_]'j�ukm����%�f+#C(O��C������w�[���ٻ�.E��;�W�9k}7��"��� ��f�K�ʨ��"��f4
ƾ��{ξ�K��ӝ�w���h��ng�4Y�'�p��g��G��?�K����g�쨋���R:m�̰�����W6�yg�26�oE=�������-	uX��`�/� u������ �_0��_0��迊�Ѐ��'����>�����?����������]�#'�x)v�_\�i�G�gmw�v�4�&:���c��%��Z�m��U��ai�1��o42U��01�4�����!�wsz��qs����y'l"*��SҊٌ>��vϳsK_Ƚ��/W����t��k���פ.�����tyu�\����IOl`q�	m�0��'λ�J�el�<b�ڔ��m�����R�hpG��kv"	4򩄟;;��u�D�~/�z+�4�D2��)E����6�i�.v�T�u�5F�7T�E���6��}�Y�����4�����;���/�����O�������?E�p�KA꿋 ��"|���S��x�e��w�?G���e��O^��;����RP�?�zB�G�P��e�w��q�_���g�dY��~�X�a�d�Q��-B�ZәGYw;p��|t�����-�C&�,]���\~�m�t����K/�,?��~�,?���j���[�~�.=K�o�e�j]^��kj	�:�d�{R�8����u�$��6Թ�r���)gh�.܎�t��b�T����i�ʹI�0q\#&�3��o!
���i�"lv��3�Z���!A��l�&�b���[������y��v��r[)��Ǣ"vn���Ž�SN����T��D�%���6*9�չ�B���
'6X�a�yHe��m5z��̱�I�������6�?�	f:���8	ǎxX"�dBb���KI��=���Kb�;�OTL���d��,�����n���c���`��$���8��}��<��x�&=!�»<M�����`�(�hJ�<��ـ	��/�b
�ݟ�:����9��+����q$6&���I���#�d���ƛ�C��ƈ��l"�/���r�ZA�#W�j��ߊO�����;����W��>u�G��?��JA����e��_������J��������y?�?c�ڽ<�:��d�\w�N�����z��A��4ԩ���]6�}�_����'����C����,����7��f�!o��*ٹG:Z�۳2k�J�	���l��SaI��%n���,��$i�V��~�^�Z��hx-53N��\m?佾���C�~�����$bq"�#�(��<}���xRƚ��Ec���&����QxJ;#�'z��r9 �^8��tԾ�(1����/�~ ��O���"�sG�l&�����a�s���Z���dp����~7�A����?��T�X��� dy����'��_�^1\F��x��{�� ��"�<��I0�g^����<ԡ�����+	��iv��Dhi��8vz�QP�ᢉ�n�ŕ���sd堑��.[��y�l�ﭨ��) ����2���x��M�e��w�����������8�_J��:�'������U�?��U����9��낲��/����?� ���n�W���?�u�&f��c�[-�o��x?���d��ҷ$������W�,n�*K{vQA~lK�H驔��O�\=�Jz���s��sʏ��\m�v���n]�v����k�����Yj_K��b��o��C^缜M�<���d�uv��[tZr�罽=�(�j�vC�a���px�R�F�n+�M��r"�m�#��D����Yw��mK�D���%�翪��ʖ(��}߹$;�����h1����F�5��x�Qn8�4cٰ�!���ĲnZwQ}��vc&Z޾��N�O�����4SM�;��DEF��6Km�ݞ���ңy��G��H��`u*v�+̈��	�������W�o�Ǩ���|*���"�������������p�[u(����v�E����A�k9��o����o���������2 ��#���������աl�� �z�����G��/��������p��OY��O���m�e��w��8��e���ݝ� ��%�$��k��� ���������/��?�B�����U�?I����o%�R��\����_9���"���@]�r!�AY��w�(�?� �?@��?|_�B���_��(��?
�P�o�W���?@�G)���DHe�E�� ��f��/�� ��� �����t�������j����_����QjQ�?��a��@��?@��?T[�?���KA��/Obh��P�o�W���?@�W)�	�C�E�E�����������/j��p�*B��/O�n����P�o�W������KB=�?`I�q�禌4ɱS?Ȑ"oQ<��Q���:ąg�8��7����WG��b����/���N�\ʢ�4����b���d��i��-\������BmH:^xWo�qb�=/C��P��z��j6�1��Ir�������-y����=k�m�<��>J�Ҧ���$��m���-�S����L�]0�5t:���Xb%�5Ze�L�y9:�vOHq%3����ݛ����uX�!��:T�����[�a����:ԁ����:T��Ͽ�KX�e����C�W>�����"����Cl$�H�5�B�����x1n��~����ؽ�Mu���v��.�`���m�$F�%C`{���ఠx���sv�
�M3�OMOҘ�i�������)���kɹwF�2�oE-����"T�����+^�j���_��`��`���U�?��C-����?�W~������?�_ێw[-��׍�A�����_N�i��?_�"i�D'2?�~с��W�y����!Jֺ;tg��dw���z���i�_�P����E��p9M�3�΄�$[��e��{]rc-�iFy��W��y�v�9�ic���:{n���JY+��I˹}��6�[)V5�	��1�b,IN�q����{�CFq}[���-�T�$~��{-��W�ϸh>MLT��g;�lW��f"���������R�E�(M�c~�ʈ��'4ϋ�xy_���ߧ�������e�v��^�q�Į��5�k�A��?U�O_�_� �=�2����������Z�?w?�E���e�<�y�:�ք���_5�����g8��T���!������?���O<����T�����b|C ��W���]����S
j���Y:������HB�o)��G�����Z�?���_��z�'@V	�����������>��?V�Z�����/���������s����v/O��4<�*���(����z���������u�y��o�4�q�e�?����~ o��YR�6�۾�����ms���܆#�	���Y�5Q%���A�Cͩ�$��7�qM�xg�4g+�K?�L/v�	-�|4<���'Ff�c��{�~oc�ȃ�_�W��D�8������v��ވF|<)c�]φ�1N�by<�+&��vF�O�f��r@�p���-˛g|�ɗi����Z~{�ṣD6�V�^���j��Ic�a-\l{2�Y�}�Z�?�����W��W}1�!�����������V���\�2Q���A���X �� �򿪭�����뿟��W}-�#�����������N���+� �dԢ�������_Q�������p�l�vb/Y�����5���-�������=a�ew,�ۘ�_�  /��1��&N[��jz���`,�6�I7k���mr9�9�s1v�5O('�wg5�ad�[�7��o�?�@�C �d ���@���h����	j&:�!��|:uve"�7�It���aep�wdCbrai�n�l�B"aăgt�6+r2�Y���؅?[}�2�ݨ��#������P���qx՗�[�������q�������F�O4xE�x�S
�Ɉ�}��	��H煐!��8<�� �96x������� aԁ���	����#���q�M��Ɠ�;#?��#惮��&ݶ�Z8�	����zZ�H�y�� �z궈��m�q�X z��,�)ϳ��ɞ��D��~��%G]=O�lR��(ڊ� >u����oE����ծ��C����uX�������������!��2��k�Q����:|d�����l��ݔ�)�(XJ{ùd�\���l�c�T$;gs��XW>1�~oCfY����~E/0� Z�!�d����N8�A����^��Tk��ᮭ���.�Y���,y4:�h꿷���]��1�����������C-��`��2����������R�4`%���c
�_E���^�_,���Y���աa$�χ��_ݵt������G���  �� ^� �i�ｅ��6��r�e���{�ҙ���'I1*�OxnwbYw��͖T�D�~tf�V3�r�o��7mi1�����2��<������j4��$9��X\=�\��&��� �h` $d�������x^_���ɫ��cG���]>YF�+^ ��7w%��*�F��I'#s$���wmM�#Q�������Ҫ	��貵��,�S�k1!�hH�:�u��{:(^v�agw���Bw��_��X�r#}�n-��E���+���к�io�E��cn�5����jk�|Z���/�c���I{Թ9<�*�ӿN�O��ߺ)}��������e�{z^�6�?�����ߧN�i�~������_��*���\Q��AV�� �ٜ�1����r�/L�1f�ۘ2��^�m�FsЭ�[�|�s]����PgČzAH��9NGv
M�&	0h���Թ��½���/��?k4};�H8We2��g����J9���v�ӳ��g���xs��0�l������;?������sqs�"�D���UT��#����0�ևv�k�
X����a���� �`������IAK�h�ib����i9��t}~���`.{\.|��Y}�R&։��;����'Gʤ���5v�$�����Β��c�t��%ϵ[��sZKK�Jڽ�um��A��R�3���"	]@~��"\�K�\α����O�xM\�Z�a�}��T9KI6����#d'�J$f�n��:ukI.�#���K��r.��d!�����ws�:T��u���}eD���y:A�p���Ƽ�����3[կid��>��
Wi2{(��Iw��)�j�v���W�qA��D&�<�j'��I�gZ�Kd��ÇO\�z�������w��7h�-�����:+�H��pa**X��wKg��<�%���W��	ꏔ"m�N�w��1�0��F7���[Ә���#�@:,p
��� ���z2\��u��QD#�$�E�~� IR�E��_������9�Wm&v����4IHH,
B��$y	�z�&�݂�� ,�oI�xN]˴��N�@�t�f�*-M�G Ą�b��Q���J��|=8R�A�o�v���E�	���ά���_�7#/���>��(����t
���N�t-t�����9n��Y_������4uZ��̧;���s%�çG�u^�E�'3�<&|Bٵ���E'ۢ�bV~!Mc`�ׅPAAAAAAAAAAAAAAAAAAAAAAAAAAA�'����� 0 