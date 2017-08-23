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
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

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
� @c�Y �=�r�r���d��&)W*�}�r&;㝑DR�dy�����[�u�=����$Z��Ų�ҩ|©��7�y�w�� ���%_ƶfwG�`K`��t7`ұ�FvDÝ.vP�k�~�ƞ�G���À@ ����xR��S�˒�D��rRJ��8�q!���Z�� <qmxf8��nz�+�3d;���s�9�9�>34�s �N���3�f�а�}b�Z���F6IY��E���&�c��c*�P��v�$ �|MX���Yg�����!Rf���[�UN2��|as�< �2�D�נ�;�:x7Y>� �Ѕe6â�#�B��w�5Y66M*nA��JU��ȥK���j.{]5R	���Eah��!fZв����E�0��`6m����4��Ԟ���n��-�붡]�|9�mt)mZek�l �*�31*\G�%Ung�u�m�?�f��6Ï�p����MO'�h@ӹ���Aأ��k�#��c<�GCZ�mRћvW[���Qt;]��'E�?���Vh�ZQ�Î]S��tYZg�n����u����p���\�Kگ�(&t��/�d"C��Q~�ͱF��h|m��C��_�fJ]�����=��Έ2ߖb��u�ne��ց�����″���v�M1:j@�&t�"ۂ�pZ���N\�sO���Ftt��?Q�؃�A^2�̋�(��B>�L�?ʃK2���o�����Q�g��j�iݗe����D�_�+�,		2�IYJ.��E���cuÊա������@��?ݰ��$�/�ju뤺�_���	<X��?�nO'�b'&�$� ��9�_9̰j�t8?������B`i�_6̰�.�ڰ����������������/��B<����xbi�� ��W�W����`���Q!�����1��"TY�\hϺ`�>h`�,�ΐ��t'������M�c߮m�A����bE6"���p ��in��_�;dK���:]��f�Q��N��炕(=���鍦LP×�44d9��J���"R�Ew��2T-��1�C)�&��Z�[u��M�v�C�tsYd	�l��2���}g�u�0����q�p��gvA$B�ѽ8��8F�}�ZK"{��)PJ�GS��&+�4/����}7���Ij�ɰ�e�On��2>\��SM3���7�!���S��%YL&�
��� ����B`<��偆g�|චچih��F|�H!�gY���r������U���čg/t�B����U�h�w4��I���y��5%iW���6�GiC��*���@�(l,�809e�a��$s8�]�˽B9d�v0� Ҡ|��a��^co� �C�D�c>
볽������v��~��6��c��d>���m~�� �¼��N��̚թ���U>�*�؞� l�}�!c��K3�'1ǟPq��������\�3\V�ʮc��HG�8�^5���:8�D�z-Ck�"��9����)'���F|���>�)3~��-`Xt��~&��D��*e������V�9��n#�~�z�8�9D�����
L4���7(G�8[h9�0c����`{?���P��r�_,��l�a���| 7�����'dQ��%j�������'eG�0~t��-�=�ӡ�ll��v7mX��4϶)�5H��>�-T6>��p��B�����j$�	���AdW	Vϟ]�!�S�X�� Qn^MW
���\�Z�-�<��� �@ �<�A�+�;^�2�s��9�\�6�T"��O�P�K���&a�J媼՚Z���
���~m��h�d��Ad�tg�J&jo����h���	�ԇ��XV�{��x6��Ɵ�3�@�$a��\Q�A���X^��l������@�ui������@��(Q�\\�]�Ղ��Z�9���������+� ��>����?�LK��X�_6�\�A�}��M����_R���xx��~j����v�a�1M�tm�0��p'�C��}�u�3�*^�?���&�D|����y��
�^Zp�����!	��,�p��OR��/� ��HT��<�,��S�st�-�� ���+е�^�v:�ҝ(GW�tv��O��7��j�sٛ=F��[I�7E�8}�E@Ӈ�\�Q�G��C� � �%������Hp+d*r���5hҜ'qO�����b��8ٰ5u`[>����K��1F,YH�:o�	���ݩW�Ը�����P�>3`��L�e�E�m��}��o���b|j���K������=/Hqa�w������<�o|g�)?��x�g���<���Z�$!GĨo�����k�:�S��h�ݸ`Ok���:�4�����$�d�����	�ڿ������j��	Y�b�h�\P�0����[ǄWpb3?j��P����B7��&S�?9�<�����?���.�'�>��>���p����^wƞ�:�Z0v��iqA�;�*�ugx�@έDa�`x� 5M��}�
R#�����<�閽6z�zqSgiƯH�y/ɥ����`�v\�f���ঐ�Ύ�{9&���+0y�ύ�o�F̸Vc�j���eLp��!c�m�.��l���1�.�v�������|iʼR�.����s��A�%3���P�@:d�DV��z��2��{5ci�J���í�����w���qy�����������M<� _s�WP����+�"-�E �_s'܇o���w��������S�Ϗ?�x]�dYJ�54Q�l����J%��$KI�d�	9UO�e�)%���5E��)��|���kn������ߪݮi���"+��7�_��m��w�8.�-ۮ�uV�i����6*�Z��W�D���o���y�w�;g�_V�X����4��Dp���6\��+���-A���`��h��NP0��1�;�?���pw�g�x���K�L�d�������_|���wLކ��_�:�2�\���e���5�.5���+��գ�$�+6������<yz�>��R~��w�&ݍ+����'(�(CXP2QoZr-.�5�R����5-%Kq�Ě-.ג0U���,+I���]�"n�Agڜ�tn�P�\�V�2j-�J�[�B!�y�ɨZ���
i�Y��%o�:(����f�M8�6˽L󨰍��B���������7Uq?�n3��܅ZI7K�T-�.��f�����y�T���i��yf�7�[Z'�I�ő�v�YS�����L��/r���V��6�W�Ӻ$�oeU��k9��zo�tfb��ZZ�X�z�ӂT���ZA:�e��L���O��b��e�Gكry3�{s���I���e�����w����Q�G��a1]�[~^,�����W����S��tZ��5�i�a���a����CE%}a���6�yn�tJg�Z���d����ܬ���mf2��^nK
jz�[�>O����y�V<�;g��[�h��TqY���ڛ����><H�����V��P��RL'����Z��,8E}��8�s��fo��VK�U���V��r�X�L�x��U����*Ŵ�X˩��Z�8�Uz�Wn3�j!ݱ���Lҩ��]�i��;�b��k�|�hHo�-��^Q�a��fT��s��B9#;���{+�k~�׎��/R�a*ֲ�_&�U����A�,�ǚ�fU�N�N�M_�y���\�WL%��{��Aqk
F?#��gzi��n�����J�f��h,�y[��j?����l���/�~n`��O��#�3C�oc�^�w��_)|��_��W�|�/aA���?���q� ���"`,Nګ�� �sG��[�X��"s�z���z��P�rS
����66b)�]O|��BU|�J���yf�H��l�-�k��+���,��K�nq�}����ˋ��1��:j~����~���������-i�hfZ��>�^mWB��Xv���d�j�t����o�p�ڰ����e�����_Y�����6�{����%<�e��Ҍ�_Y�,�����N!3>��۽\�h+��Ȩ�p+$���l���`�g���}X˿)�6��#�7�.��Ŀ��n�8_l��U��z�J��������N�µ܎���������լ`Vmnl�O�Ӓ}�^���'���b�X�0��>�ů��`���,M��*2�������dp�o���B�H���(PMTh�*����\̽��Ȏ�m���m�^��o	A�<j�����k7D@5�`S�A���e\�it����� k	XXg'dR�1y���<,qJ/`��#��~�f��,�@�Zc�U���yS�|��46�U� }�@{ԑ�{,����]0�H�0QF?F����Y�@w^������̶GQ�$���M�Q���i�tz�c���߷h�-ͣu[즣�&Yd���5D�4��p�/\���L�鬠�=;��OԞ��*
@�� ϡ��=z�-v�)5D���o�>��k6=1- m�)CZH�rm9�v����>��T$���0 S����t�� xQA=�,/VA�Ŭ�~a��(��-'��zt�N���|�x��\4W�,t��A�腶ab�؆���		N��)����ß{収1Ix}�Ǯ��2:l�`%�|M�k�w������4=����;L��4=@5�1���+`#�K���裩�����Ƥ����b�OJ����Mq�+%)�2�M��넬"�����l��"�g�Huh�)�x<�2����/$�ý���I"R��`������0Eءi�,s�������W��ĸM�m�'j������x2س܈8T�#�ɯ?�K*�S��̈́�����? N�+b7_[::/���j@.hfh�}�&��4קOM��p�W�&X�ĲC�Ȏ$�ΐv�T����T4�s�_1l�`��m����dM��f�FMJ�o��u4��M<:!Z��5ʷg����6M��H��H�S��q��u��>ߺi��%,��n{�2���|,�a��7͜�v��c���6��tnP��3����:���x,��$���%�u,-w�4M�nz���f��n�Ž~�v�b��v�$N�y:O%'vW�G�N�d�.�4-�4�� v �!1�0,����b�!v�|�q��U��.�V׭�����s������X�k6ѷ��vա���'0�ɕm\��������������<z�����g�?��.��w&E���~������?�����ֳ	�.�|�#�Ǒ�kG�����7�~��o���'��|�IGbE�1��(Q:��$!�-%��U���N�)�'(��)8AP9'���E�BC�ʯ����o]�ďc���?�ӹ�������~C���~����[+����C�{�6�_�~��������b����/����.�-�woB�C Z��b��C��L+ߋ�*Ǧ���U�8�X,ǜ���E��/�s�.�
�-��W!tUSd�N�X܍���";rXsQj�ٝ�Q�6�-B<o���"%�7e���yV��!bZ�'�L�A�5$F�JbI�xgho��Fm>n��@��d�4o�=�[fz�An�&r3�Է��p��Y{��yvP%5�j�*�7Œe��0����y�L��x��j�_$p��r�~�8���;P�=4�|�2-�16N��	n��j2�|�X+���-��L&s�2~a��T�B�����I��@7KX�)�Q��׾��L"�2���L#��I�cq�,9�+�gKf!gE���nJ6����wӄ�O%�B� �e�F$=+
��"��;����Q�Jv�%F�&�sT���lC滢���1�Zk�
=9�Ʉ�����4;�&�T]oW(Z����Ĥ�1f6n�R~n�'��X�x��cU���������_�Mw�^"w�^"wE^"w^"w�]"w�]"wE]"w]"w�\"w�\"wE\"� �W0��F9��7�O���õ�R��9��?�Kx)Ξ/q:�kbz)1\l��^�Ί�bMI͗�=wQ=x(��V=�=�S=1+m7� ��ϛX+};��x����,�t��R��42g��q�EL-ڬI���B�%�Q��&�JK!B�g����@�ɊL6K����	N���H�PE�z��x��y�O�9b:�	&Nb2��ٲ�'�L�e�|i���"�V�W��.U?Y&=#�y���8����RV�`+��6jݸ��"f&�S���ԳQf��t�P�T���ѕf%?i�pr���$�=��2���_��N��^}:
�i������no�֟_ [��y	����J�7�>C�K8��`�oo#]k/B���>�z�����P7�~�Aݚ.{����q�BGv_�}-��߁ˊ����[�(��B��M$�+��o>��|���<���=x��׊���e�������%Cclm�㣥:�t�[:_�^��OrL���	b���V�,oQ���Bnc5����$r�9(�Gt-��.�ܔ�u��x8�o�BA��R����]e!�+�!���ňf��Ev�'��)��3�ܸ�&ϋH�.��٩�� Z���6�
M��צ�Ġ���q�2�M�1b�ڲ>Hf��0�TGx�B��w�L�x���'�t{9-�������� +1@��Q1iA�E�M�r�_4�A�S餎��hԔS�[�\#Y�j���/�SdMQvsi�cyFc�����.�*�A�$�%���mAt1���A�b��銭�>ƌ"���;T{��7g�lM8ϐh[�2:Y�^�*{��o\�4	`(�|C��Ƞ�P�i6�ǲy�;핖[����EdO�g7�䒩z27��<���\ŒuN�#"�X���E��/r��~&8�8��U=��#��w��h�3�{����j�����
G�[�e&�<WLC�%�+�l�h�i��6��pXVsY��_ӊ��Z[&�����j6�Ҡ����EQ(0Ø�8��C����;T�ʈ��ʼc('D��Nf9gEK1��`.R�n�@
�dz>���q�ֻ8��tb��l�B�v������v����cDyzڮ�
j�YU3�Z_�(c>S��2��@�h�|z^*I6�t9���ҩN?��>�t�Åe��x�g0#�D��2���粉��Z��I@�,V�D����E�"g�JO��[V�����HFV�q�<�ُ:r�#1eAe����S&���R���v�S&%`�{
	�y�W(��0R�Tۧ��A����S�6��>���|�`:5"6k�B������u&^n�P�5�x��+�Q������t�!�eo4�m
�i�
%Z�6���1[�.-Y�K��*v334]���Ub��&H_&Ŵ�!y}����V��x��P��|�SJ��4%�^���l��:A���|l�0Y��ʬU�7��<hY"K���k�(G���l���<�����ɷK#+���C߶m�������A��/D�v���DV&��6�/ \[���Ds�������ip����!-�j��Л��H�Y!?��f�W֖j��[GȻϞ=�?|�,���6�6�#9��B��@�F�<;|�|��0���)���x���7�k�R���1�nZ6@�ZF��z`�#������Y8N6e�@~�N�������g�w��ae��j���C�C���=z]���Y9B^s�;���[|�x"s~3�/L�|���Ȗ����o?����6��'�~8�u�z�NG�~'אn��;�0ZjX�n�p����ۏ���d#<�'�@5�SّwR{W���}��rGd������>WƦ����W����]= ��=	��T���!D����y�tu��|f]/���u��kZ�[u��~���9�щ����.�vLM��������"�	:Y�O�R	� �\ �O�A����]�( �� ��f��D���67 D� FW��AE_�oL���v����<�cxj X�x�,pX0�Fo4Օ�P�u v��i����3_���� ���|�V�ت���$��sH�q��,�Qإ�`wA���9��
Zt�78�@} k�u��.����Ù6��~�5�>�\�6��Dj���Y@����_��)X��'�M<l+MN���l�ܡ����5��+s�:	�]BG~�WĀ�Mt`���X�N� ��&��G/���VB ؆��6lkcY?	�Fv�"/�|	Y-j%�ȗ[/$�̀\3�cus�7�7�zP���f�{�	�v�!a?
�Z[�o�æB���"������0�����6�n��CW��� :]l*DO��a�7��Lw�]�[޼���Kh���\��A��Q`[���S$%�I��4���|nu�Z]����E��͖]����А�b�	�l} �u�dMT"[W���6���r_����}���� @���Ke��D{Ꙭ��e��~�%AL�����m�idq����+Nx�l��u�b��c��� �<�б�~Z�� tFj�P9�ea=����0a��R������eQ
�9� \�U導5�"�âS6���sm0�j��v�N�P ~6�{(��[�BƂ�1-{���nͲӞdg������@.��~d9x��^�h�nKYuqձ'+�6a��6��E6ػ���Ŗ���/�a�{l|��۴�#ƽV5���-B$�M�6��[�d��N��|��]M��SwFN��Zf'�>Pv�ùt�[�H�P�fu]���ry�?x�P8�Q�#s�6����8}��x:'q,N�$E�r�ky]���N��$p���n(M�D �o1�n�+��0TMk4�rc�R~��qC��~T�P��Q�b��];�����p��u�����1q�m��������<��O+��$���dG�GV�@k'7��rv<���I�-	��sBc<EU����%��|�ʗ�o9ƮbGo���*��%��_m[��<�>��4t�7��� ���!�-*'T����Cӝv[��J���2ъ���	��iu�L�1U&h���;�����G Ċg>s���fi/���d�?��~l?y�
���x;ğ0�ξ�x�*�ܢ)��jad�*��*���,�4M��(�cjDn) ���g2Wɨ�˴��~�r ���c+�X����6�j`���Ͻyn���MG�.���̹(���팻6;���x��>x)��K_��:����=��SY��g�*jkڽ<�P���q%�\~�A�
�47��,�E^J繧�������;������J0Y�\�����r�XW[]c����*�Ʒ�dg
8�AGc���jL�hW3{�$���Z�Z�E�N�Fg縃��ަSo�ֲ=���(
�A�`�[ݜ!���G$�	����i~;��ȗx@�)!�:+�|i����D�r�<���0ǳ��z֪x��B^�IO�Cm~��(�j���	:�]��$PX4~f��H���]2��ti�o\>qjM��R"�K
��/��S��S��΂�v�]��Lr;��ԩ��H�m���e�<��˖%F❟#1,S�&@4T��""_I�9����7A^0U*#_(���[|M
�<vg^�|ڑuC�����E!�`ܱ˸�'��u��;��@���Yt7��f��u�e�Е�n�_��u��l�mp�i���%	 �<�ح��|W˛��zw,9 ��G{V)e�66��B�@�Eg��7�>��������M�M⿬���N��#�q��tG7]���O�z��酯������G��뿏�J����m������>���S7��m��>�����^ҫ �	۔�T�<��}�}����/�=_ٴ/���_�""�����}/����������z��o�~��J�Ԏ�_�o/i_����e{�Q�։�ܖ$�)�N�j��܎Gcx[�cX�iG�h�%cjST�$�����^���Ʒ��C�������&��Z��64��H����r\�:hZl���E��H�a��yu��^�O5����)�-c���ƌV"*�5�&�+-
��XE;����y٘����I9�8�t��IOO'�,���6L�ƨ�]����v~��U������K/_�;����!�N�X�ۜ������>ҫ �	l��� ����%�/����� �����������>�=� Ӿ�)�J���?��{���bo������W@�Û� t8%�:�����w�O���>��}�WK�C?��P���޵5'�v�{~�{o���p�V}�TDP<p� "�@QQ~��I�{�u&�t���ue9��]�����U��?��${��$��T8��ꄣ:��#�?$��`��?*�/����P�n���3w���!�����B�����$�x���n������t������a�:�/�B���,k��)}��tn�����~ޞÌ�������'���Ϣh?�̪`��}{�/k���"	v*)�j�7�R�^�ͬ�[4{�\��C��Y���\h����ut[��5v� [���y��]q��C��� ��_��|Y��~d���;.W�yP����w��2�"�ٓ�M�Ko�]�َ�۽O��_6��� M}56�Y��L�Hz.�o�-�P��z��Z{�]��Oc�=���OY�:��a�׵,rT̚�(����i�����m@@�=-��P�����	���m@��!%�j Q�?�"���J �O���O��To��@����� �/Ob��P�n���?6����@������������;��?�V�;g�9Ӄ8gI]��ɀuS�7����_���뿔��7]���z���`�q3��N��h<�k#�k7�h6F�L�w��e5/��7
��IZ\r)(�v��s�?��A��v{;dM�P��k]��X<����N�l�b�?��KI�
-����^��om���_8�����	�)IL��9-�+��FJm���1���IIf���m���)�8^�&-I#�z�dO5���3M�/#�#c�1��a��$��@���� �o]�C�����P�n���S�}���_	P���< �p��g��3�38#A�Gt�\�aH���r!I!N�l�P�g�8P��G��P�W�_����=O_�)4[M���4�O�R8gQhP���l�]��/������.N��8�OPu�"gGB���t�����y`��m��l)9���籚(����K�΂�3q�p�Ϛ?�@��[����?�C���������?��	����ڀ �?��?�e`�o�'
��_}����ѴT稫��vs����3�uW��n���;���K���(����x�L8߼�lW��nۧ���v��٣�U��2O����e]H������M�y8[���t�	<꿷��?	�oM@��������7 ��/������_���_�������X��w��(
�_xM�y�U�����ALڲ�G�̈́�BM���.���%��g/����0Ǯjk�3g `OO�� ؟���3 �R5l���R|�T��! �� Z�yJ]]l6z����tK�𕷟c�F�)��B뵶K�V�m��FlG=N����1f���|.�ެ�R0��2���=끾�_^�-����ʷ3 ,�%�t��R��������蓾�i�� 2ۧ��<Q��H*7X��9�Sv?7iW�9~�@���!5��VZ{�x|�I�&�?p�@(�%k�H���1k5�ٱ[�Rc:�;R�L���b);��Ft�/�=1���Ќ��\d�ׇMjt��ag��">K&�_VNW��E�P��@�Ѡ������C&<�E����~?���������'�������?d�!����G��o�@�����������7������P��#?`?��qn��2�C�|�gYZ�8�g�����4�"�/D4>�G���a@��4��C�����_�W����t��c���D����0w#�dM�N-&�2�k�`����b�%�4ҭ����ß��n(��%�b?�㤺����e��K�%O���c�p]R���@{-g�ǩM��
������*����-��W	�;Tq�����	�@���;���*B5���6	d��������$��?�����x{��FU����S�U����[�7������vd6.��Ծ�.I��ں���Z����VIs������9�gf�o�l�g��bl��̈�;Ւ��:��>��Y����l;�(�8s�L��9�������V���󩯋z˟�I���yY���i�1Y�V/��З�#��nc�^���~���Xy�8���{���4I���ު�7�lcG����{\n�FBv�������X4TW�,��u��d5��4�y����\l��hLdo�n1N�k���l�1��Y�J��W�����MFFg���E��43ݡ��Xve@A�]���[��p�;����s�?��$(��	��?����G����U����o����o�����8�wX�` 	��?��C����_*������$�������_����_������`��W>���o����	x�*��{���J���8~_�S��U�*�<������_?����u�f��p����_;��?@�W��!j�?����<8��?*Z��U�*�����*�?@��?��G8~
H�?�����������͐����H�?s7��_�X�(����h���� ��� ����W���p�����H�?��kZ��U���A��� � �� ����������J���˓������[�!��ϟ���?��^	����(��0�_`���a��_]������G����Ut��>��@����
�O}�Y���J�OW1��s<�x
���C:�C�&��"���xH�x�<������4��/��O����b	��k���P]+�������ow���O�����XV��Z��Iz�4�d���G�ML"�=^�O���P���q1MY����[�9�wU�|�k�#z#��F�=Z�k�\��:b�Q�l'��o�4=:}2"�Pl*���S:m"�X������{Qu����?�և����5t}k
������?����\���ߌO����+�AH̹q�;E���3����#����a������p3u����hu����,�t����B�%�b�'3����љ8��]ӝ�`?l��ivn����P}�̚Q�S�vTv��`�2&�o����������C��p�;����0��_���`���`�����?�� ���e�����x����O����O�#J�{vkO�|y��*s�����{�v7i�H�䵉,X=ց�[2�����W�6�i%�X��L� �;�͔`7N�N>��~"ڽx��Ü��0֗�R,˃��S�i^�^�ftI��o�F;-�{m7���ӷ���K'���-�%�t�,�XmI�����e�>鋝f"�}IJ��aߍ�rk<���>e�s�v��~Y Ւ�wܝ��I�I@%�L;���ۜ{gon�B��[y��H�p2�����S��ū��1D2��΄iD��jη�������?���~���|�7���ei�ao� �Q8���G\���~���������_	P���A�'�W����?%��������8��8	��J���8q������@5����	��*�����{����,�U�5��tdY�]���ice�I�B�z��Ow�"P~u�GK�����Y��g�M����^�{�F�x�������b�a�<?�P�/=���u�R�b]o��͹���`�-;�#���U�����$��:���,w�r��ٵ=P����Uثm|��r.��$�,[�I�l8�E���MF:��]�n:Z��u�O	Ɨ�}J�����-Z���{r���K;w}���O��cQ/������)��4���L��D�%��M�Ր�ݶ,������f�bˈ<��[���q�s�c�#*�*&��%6/1�e��|$��h,z�8��x�`��d""��K�����>O�	
Cb���=�����y�X��ʺ�����������+B5��<`	��9OФ/̩��O�l(�q������)a�S\��L�G�@�3���(�P����_���U�_9����\�x��6H�u�c�7�OG�`�/�Q��F��ȅ'E_����ʟ�
��rS+0��V|���f������U �GpԽ���T���aTq�_�����?�_%x���7�����i��w�DH㋩r�	;��w���T���E��@�Z0O���`��������a?��ݬ?���Đ�������~��|?�JvǒJ��Ꭼ�vJ6�ZK�=>�3aC����N#��/�!+ʛ 
�]�-��|\N6�n�hYwt�����~/�������$�،ѝ���q���D->_�i�NcQ��JQ��~b2�.������lF�D�^M��%ƙ�i囕[��~��F�_gxn)s����т^G�퍵e�n��������-V������h��+A��gC:�X�'pjΓ����GE� `|��}����f<��>I0�g^����@Tq����X�?*����Zv����h1~�<p���N���8��|�+E?TE���a'�����l��콲���⣿����w�E��WP�W�w��p�U��������?����_��b����v2����������	�%x��#�����?Z�nS�܍e{=��������?d�<��5$�%�������R����l��K���A$��Q)C�^̥z1���\��������s�q[����l���|�y����Y	0�����ZE��`���h�����{&�L�a��HQ�c8��:��N��{�h)7^f��o��z����\
���k�����w]�m%���uNZ�Ǒ;�v⽣�;�=U���5�U��׷Z����a`�O�U���^ÊgIo3+S,�o�jG�J��\������V�)G7JxYBSH.�?ʗ��� $�˼�R�����xsh����0�S�������b[w$�i:-��ȑ�yU�����UBS���I�c)����ƫ�p�Z��k�X��d�ogM�v���+8�SRj���j�*�mz�$�����H��R��K��g.��Ƀ�G�Z��2!�������+��߷������Б��C h�ȅ���!�; ��?!��?a����?��@.�����<�?���#c��Bp9#��U��T�a�?�����oP�꿃��#����_���#������gH���!��_�������_��C��@�A������_��T�D}� �?�?z�����X�)#P�?ԅ@�?�?r�gn��B��gAN��B "+����	���?@���p����#o��B�G&��� )=��߷���/^�����ȃ�CF:r��_�H��?d���P��?��?�Y�P=��߷�����d�D��."r��_�H���3�?@��� ����ߨ� �?�����\����}����F���ʄ|�?���"�?��#��!����\�$�?�@i���c���?:���o�/�_���X�!#r��&GS�E%~��f��ynn�e�bL[���kY|ɢL�3m�(�����2�9�c�G?����Ƀ��k�������驣�-������Wj�#M���ǭ�o2��oE��_'rMT�D?�t�ǝ6w�ɊqHS,��8�mu�/����ȉ�d�)-z�y�z���v����tX��vX�����5Za-ɚk�'�����5k4�ݎS�c��De�'^��$�G���Wd%�܏���E�n𜑇���U��a�7���y���AJ��|�c��n��%��:���'�N�Vv�^����^Hʦ���㬧m�����Ι�_���<Z���`�1�����fCM�"vX*�h�.����oՊ&���ù��Uvy���|��ƞ>�WJ�)�O����[�G�_��_D���M���F����/��B�A��A������h�l@����c�+�����˂/��{�����vˉ�j9�޳#W��>��t�_u������X��L�c%~f���۰ףm�
b�,I���,>���?֍Ѽmx�_�ø0��qa�G�=�N?(�&�/O6�:���ms�σ���w�RT?�V�/���m
��:�����*�W���-�ʗ��	EG��]�򔦐LE�;�����d.Ij�}!v�pS�*����{m�a�l>5����+�p:��m�QTW1�ͽ]�u�]�a��L��q�i)�%L����(JB!�.�����!C�G�����M��۵�.�Z?����<���P���� �#�d��i����A2�����F��������5��O@�?�?j���+���Y��,@���$0�p����#��F���dr��8궸G@�A���?s#��3!O�U �'+�������/����@�G����\�ԍ�_��2��+@"�����r����2r����#r��s����d��?N���c�����A�q|l�|o��m�*�Cd��a&��s�G�>�~�+�o��]=�~���+��������8|��m����o`o���ݸ_�'�Z�w��i�Jб��.V�:�x_��7T��!UcZ+��3s����a�Q�$�a�Q��&���j���i�ط�����b7�~uC>m\Q W�JAx>�+���X�V��b,���I�c��~wbW��bP��p�Q�����jҖ��C�э6�abb���M��Ȩ[�)b!zւY[���k�ե���\�����������d ��^-��-������˅���?2��O/a Sr��ߨ�E��&@�/������Z����D ��>.��)������˅��$�?"r��7���M.���GƗ��J����������"���FZ�4'ßj���|���$Q���������ft|IS�� ���9 �}����ǐ�xu�^�KjE7	��5m�����O[�fi�ž���U9Ө�hG�6��Z�K�[�o.�*�q���� �J vN���^"$=Au��uaQ��K�¾/�K�<�o�QDը��Z{�lt%Ud���Z-�(����Y��"�h�ขaO�n+1�O��3�����@��L@n�}XuK�'��߷���/R7�?A�� ?�ϔ�ԋ�ms���K�5/�m���1��6M����R�M�<i۬i<g�K<=��я�f��������l�����w�d4���?a#�<��N-G�~4��ښ��ZӸ\xY��X8�����&N+8��Y�ט�b�d8E]o��s�;�\��<;Z��4׈Y2�m;��>v�e7����o%�?��D������s�������\�?�� ��?/������.Ƀ����������z�XV����Ĝ�*Ċ��K���[��ڢ�S"7�n_�?�/��p��� �0���cք�P���ł�ؗG�,�x�F����v�FhV�V��x�Gt�~7�:�'����{+�����X���?���� #$�_�������/����/����؀hȃ�ǲE���%�o|�����X�7�����r��w������s ����m9 ��B �s 
+'��k�����-H.4;�Z��z��jQ�F���OelE����G��O��bSlk���>�z�n�fԨҬ�ڶ��RW�O�<�l牺�Ժ�v��t�j=��bwX��`��aUL����ح������	gXJ%ŋ��V�U� d���q48V�UD2��ˇ{�����қf5�hk�e?5��j�ö�G{��p�HS�h�+��i5�(�ď����F��ڙ[����i���Xs���r�Xp{j���#Z[����·S�G�e�og0~��/�$�����?Ƈ���_��I��O��f8��ςKw�X���B=��������O;�ǣ�I��a�W��J索�#j���W��~��|�� �mwm���Ӿ�
J�5���.v��������zp.���??���=�Z�J
�����^Լ��ޱ��k���l~~'������)��O[���}���(�����y���?����z��G�.��=�v�(ƭ0���A�z1����'f�{��������(�n�����]Z�s7����XE������?��n�􍕾�M������'��K������|���x���W�Q�������w�c���p~�/o���Nħ�<7k|�'޷~v���u&z�6��c`�kk�X!~y$��ǟ��t7�3���}i�O�x�;�s=_�~h��n�,�SQ�����@m������^������ư���,s���vk�߱hmY�nM��"����Y�.ל��e�e��:�kG����q�r�����O�d*���빹	+6����#^���P�OV�]�N)m�W���U<�������;��{��w�v��*O��I��v�Y�.�~�M�޽�a���}0>����|G?>��w��                            ߗ��*�� � 