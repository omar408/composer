ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
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
WORKDIR="$(pwd)/composer-data"
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
docker pull hyperledger/composer-playground:0.15.0
docker tag hyperledger/composer-playground:0.15.0 hyperledger/composer-playground:latest


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
� ��Z �=ks�v�Mr����[�T���X���f�����),��K�d�j�����9���p���7��!�# _��3��xHF��5��u�>}�q�ϣ��J��hw:�7L��k�~[{t?�a�DD��
���@X�"����qR���t�4�p�T�\p,� <�M�U��x����E������BfWU���0 xs�����_�U��:l��a.�T۰�Ӛ�25Tk 34��M)��1L�rI [��6�C�ۢiH益���n�����R�x�8̧����� ���V�f�bw����a~ٰm�Q�cP,�K0�b6��ۖ�=���#�L��VuvN��������b"���+�Tr^1\�6�D�h�a�"&�Pב���D}?5�z:m�)6�#Ө������mM�����k~Y��vlw@ؽ�iZt� 7����x�u�y�-�?�Z�6L�jm4�ơ�pB����QT�fͭWm#�!��9x�YC&�r�xv�i9�FXo�e'�(�%lw4DZ��$n����=)�Bq��}�Q��9��V'�$e��+��U�-���ߴ�n���;�~q�����n�lP�tO�k���J��7̄:7�����&���|[��O�;w[P|"�tG�n�]�(^3:�{�٢�Jա�y�����Cm����]�.�w���
��n�l�x�����E��,���P���<��D^���9�_��7e�m��(����k�j.[i���ǟ�%O 1��?*��Z�_<�C���*���e8�� ��(5�QSM�b���ri�tX)&Ro���,xƂ~ �^�k���,_�Z�k�)�Od��g�A\��*`-�_7L��|C
	�,��N����-��$<�.�Kk�_����)�߁J6P��2�{����ř���d��Fy>"�8������ q:^7'u �<�,�17u�5��2A��Y�6 �Y�pق�a\Ҍq�c�ӲA�1�gƫ�c�]�a�� �d"��چ�z�ކj{/�#��	�pNө'Vhj��6�
���b�c7s���J��i��t��-c�i������3�gx��%_�.�����&z�Y��ҡa��[Y���Qs�����T�j��؆�u@ @>����"	X�G����D�א���G�`Jc��ې�W���š��������&rep� �7_3����9�YӒ4:��	�@�Ê_t|��Jȯ��U�_�c� �偺��`���-U� �k�Dm��p"�����-fXȲ���g�G�9�w7���><c�:xK��#k��,޿$$u�F �i v�GhC\��zX ~^���!/.��@������+�+��څ��I#�ߦZ�(A��z�I/��h�{�F�- -�C�İ�\�gG#�=���m1�n�y��c�.�4ޏI�]���Cf��.��L�����X�*`b�֧��_]��>���!�܁�
���ȅ1���ڴ�f�}��;��a�J�]�HC�B�BRl�k�JT�� ˸_�ݧtr� �l�z��@��s�T�>c<B}�:6��۟���3ឨ UnR�a(k��gT�^P�Fy����D�CD�k^�,@Y�x�R��tdA��:Zo�_+L���D�7�/���#NX��������)�?�{�c�����������p�����jg�Ӂ�h�hzD3�e���1a����$𢁕��3�lq�V���-����Qy��4!����)vE�0����C��",Q]9p��ܴ/f�ǩb){�~y=Қ=�w�pt�/��n9mR�{j�_���`���w��A��f���%��9���%��M~Ke�X>/gs��Jy6�ch�x�%��Bx�jֳM+��Kn�Zh�ݭ?�����7�\���۷`sjŻ�&�߃�EBu˙��<��!Нv�,x���j��'eI�,h�d��!x݊'�~�l�[�<7Z�����E�W��͌�,9�D�2��"�O�D�?��r������+�����UM�7XN퀩ӉHqu�F��j�nm�傼� �q���_��>0L���iߧ�H��<7i�E���w%p���<�T���iU��i ��C]���2�m�k�si�"�
��u���w��f����
`��Sg�Y�h��?�G��<���z�W��e.,�������En���&�)b�:6�M��4�蘪n{�v�5+�<��d�G6�u��(�c"F.&�vq�h�2�M�d?&[j:6��Q�7c�ăEr��e�6 ��0��"O�^d�Lo���P��V<�'R��x7����2a���ij�5rH�F��f���tx��B�j��Ş@ݘ�諈�.R�cae��OĜ�j�Ɲ1�)V�݇�6��h�Z��-�m��e.�,������7�����:��X~�%����+\���Z
���)�
>p׵ 38DJ�ρz3�\{ޡ@�rAq� �{����;�a8J�V+2�o+��\
Y �aA��	K��H��D\��
`��{��0�>�[��)Hi����^�Z3XpHx+n ���w�"c��Ϛ��Q���ԛ/"5���^�A��Sy�)��KϼPԵ��m�+�������J�i�_���_��|���^��"�'������0܈����垄(|�J�c��͆=��*3$��G�F�fM�E�<���$)_��_�6���qy�T� �#�@�p!�V�*����য়@�0^����5u�!�V	�:�=3|�e�{-SI����w+�F�4,�}��{��{��{@d򑐱2"�b��ރS^��x�h�KcuM>�1�!����7&���Y﬌�Q�\3x�樘=�˩�����+	o��m㤮6�K!�&��+H�8�&�,DJ�Bt���F&f,�Bظ��y�*���j�S��an��CuE�n+1Q�0/E�k�S�"�@~;
cU>
a��=�ZL"U,��kKm�d��B
��`��@W3�kzKt��8`�͂�B�P�(�rZ��hxH����ņ���L)H�`Em���1�y:]��3��������J��?�{U�;����yfmZ�n����h�5&pw��Y��W��e/I�8�'���_|���8��m�VMo@&����ѧ��o�S�Dp����n���
[ ���q}�cE���?�W�.ѐЏS�'�!���c���������mY���L���%Z���ҙ� \��B�W��~'Ǡi�kڌ�g��L������s[��&�8�H{|�!�͏{�����d�ņg��zV��̛#[̝��a�t֋�K��ޯ�|�o�j�}�A���������<��E�]����:� �y�����'IRt�������9g������������ؿ��~����"�Bl���
/�`�Z��X,R��Q�B$�H���j,,*P�I�_�nKBu[�6��[���2��7�a�V�t49������d{�x��&�$�2L[u������`��_�l���q"���wߌ�,�;��6�y����f���q��o�OLl����?m<�H3L��9m���8?z����s��w���ީ�;������y�o��?<|������c��/��?f����Y��+������bj�5�6�4�BBb�/XX���
݇�X�{�M�Sٝ�,���z#K��Q���*�!���/���S�l��Y6�M��M}���D�"���DC�e�r#[��Ρ~�ޯ�♾�&���V�%��}�,{u��0nO�J`
r+#�T��K�.SWr1��cR�D+߬f�v5�ځ'���\q�r����;]i��SA�:�/3e���a�S�X��*圽i6�o��YI��
��^R�.N����w�A{*fo���se����
�r�;,g��vAӸA�;��"^��^�p�<.2�����U���GZ����Bڂ'g]�-uN˩�\���2��W���M��OO��&Q�J�sq�bȽ�I�h�I�}��J��2i[�\j�|�Z��ឌ�2���L)'��F*�Hx�{�=���񌳽/��e��;6����t��B�#I�'�����~�:9�j�J����iX+�����E�:��v��Z��Q1r&���Fo��\��d�涖��^���^#)�H_�sq����/d9��H�j�^��K���x�<�N4�����f���o贱d���%ґ�*����,wr�1l���5�\�����_����Ƈj����*&��BM��y4��PI?��c�D-��6J�~�h�_�kF�Hu`*��ŢN���8�w9��c�n-_)ʻ�t:�S��1`�����`��Co�z����O���O�w�u�\�8x ~�`����a��[��+�O���]��i����5�h������O�����W>=�;X�S�4�1��f��,�ۣ���U(48.�;8��j(������١|̕�7(�9Ѵ��N"媸_���U��,�n�*T��N�ҺJ�D��ձ�Nh��*j<f��V�_(J})�!�r�'d�F�y�W�)
H��JV��Ar�̡6��F.��|7��{�ˁe�� Q�Ա@�yQ�N���$��%0�Nb�5��e�$fY#�Y�Fb�5��e-$fY�Y�>b�5��e�#fY㈙f13M��� �a��7�?im��>���T?w����˰��i�_x�����_%~�M�Ϳt����yz]B.u��\P�����ў�J'+��~��<i8!�G�x�?f���Y:�J!�)��q���X�0d������l�n��Q�?���%���r&���߀���s��o>A�}7��}��ֱ@�#��������?VO@���Mz.>���NȚ�$�ED�E-�<!�쏒o���X^]E����È��L�=tO����DuUW�Y�NN����6�a�\��N�ݨ�O�%?���8��U� � O}T I�U}��������PdK��Q,!D��^U�=z�,5�����qCY�6| ����B�7w�"�{�YLN6?�p�P��?��m�c3w�x�CO��_��%r��nҧ���$�tX�ܧ��%9��XD�S��L'�@�pL���Q;&�WA r��͠G��A�>�M^�-#�}�F/\it)xth��PP�4a�TH1_��"�N�=`��'u[���j���
���ۓ	����{�ב�ff����C��v1=�̛�y/����֎���8�N��r�8�8q:v�$����ˎ҂悸������r .+b.���g�*��I�^��H��^:)W}U���WU_������t8��������)���cˋ���QN�����E0>�mA
�-f{�Cw4��3�|EC p�Aes�?v�f���;:�&���]���;���?y��r)�ɓ�+�x��dt��q;�v_�����F��\	��W�'�T�&��檱|tg���ۣ�7M����A1��>L��̇ە��üt�N�sÌ��ZAU�}@
��s|�<�a��M�������	��N�@��t���m

��]N�|hL���������+���	<��"��9���Pu꼯컥bH�����~H�d�1gP�-�|�Z�
@-Ě�|�}�{���G>+�|�D�?��y�Xf�W� �dOg=��*�1���VL�فl��N��!��B*=cfA.����F�Jʦ=��y"ݍd�j�6U5���˲�q.JtT�=T���p�{�a��z�;�iCƑ�z��`�Fh?$�Ae�t��˜�<�_4LO����;�,[��{8�6(�V�z�E�Bms�)"<�kzG-����k&ѷ?���c���G8��u\=������?Eǿ<��Bb�>/|��џf��������O�2��4��F�o�����~�O�9�;�)E|�"�į������_��>+�:�u_1�+;��g�
b Wҩ�J%b�DZV�TVM%S1�Jd��^�N�ɌB�t�2YZ��/IZ�܏��ɯ���o��ԏ3���?���S�,�ç�=�|?F|7��X��&^_���"�v�o�:`�Ϸ"?x�;��o���{�W�f-��"�ߋ��=�=���߾�y�m�:�WG�6x�+��A&�:��R��&����r��i��Y�V�s��B[��m����c"�w�ٞ[x �w��=�5���(uh~F��Ȩy'���Z<�,ĳzR<���t��A!�EnŔ�����ǒ����;��^L���R��q�~W�J�]Hh�qi �*�]�����wp�#~������q�Ӧ�Кu�-6���<�/*g�frw�,T�:M�:,��auTZ�#�|>����MڎtޙXG�ʮ�71,C��|�To7�C����ʼI�;s��h�`�� T�b>�p���X���,�^+�D&���K?"�)l�`���%7s�a������=�z���V �q��x�H��Lb����薒��L��u��\�;�a09Ol;_p��Zn9=��3�� ^mb���Ձ^n���$����Y�gZN(��V2��f�n0�q��O�T]���0Q%����̱Ռ^�w��{�rӗN%_:���s*a�J��,2t�5��L���ZFirH�j���HT#˞��T�ҍ��xyQ��?������V
��t�Q=J��[��۩��S�H���nL.�N���9�W��lkҥY|���.U��z�ۖZ���1�f�]�����-������m!�ȷ@��p%[;�R�9qL�O�S׫��?Ϣ~�]���l"�l���W'U�2�*`�V�K+Bʉ��Υ���l�"f|>�R�Q"�%��Ŷ8'?��L��R�JssRN3sΨ����G�z��mU���������h�I��+�,8�������#�D�"�����t�utz׳����	ߛ���߬DpB���[9�tM��M������#o�}%����;Q/_�ۯ�z�.{���A�#�=ؖW#�D^
pY��ￃZ��"�{'�/_'B�\���{��ދ��^�w��Q�]+��+(�������W%Kgkl{Y�Ӎ����]��@z�:?�1M_���m��9yW�p��D,�%q�Y��ӗ\�m���"\�Uwx�]��-�OD��K�*�a�@&J[b$V�y�B`׊CdY�����,���/�g�\�t�Mjj��NdS�D{~�dGT�:�	r�x��b��~4襘�HV{֤�؋n��2���d�/i�0)�T�!N$��J���X-��/�8��ux���Z�`%	�bT�aZP8���9��j��LTәV�p�;>H�mP0ϡZ,�N�iڌ���#bCQj�"ñ<�3����N
2%Z��1�ԓtbxR��K�Ѻ5���M���$fչ>�cu�0ԃ�|\ng�D�'�F3:]
���*{`�7�e�2���P�wJQAh���\�3媥����?y���%������r~��27�|�H\�&N8���\gY9�n��&L�4.Hs�������m��gw��gL�k���C�m�ꅛ�p"<�\��3Ŷ�v�f�5`��5�S��Y�����Z)G�m�ޚ��U~�%�QV���u��\�ׅ3�蹳a�[aR��y�"���2"㸆2��9�a�#�Y��\�LFk�b��굄�勋�f�g������ĞF�l�\8�r��xAU7!�F]0"��N25��=VK��Pj)��L�K���wE��h4$�0'%2�b�?�u�O3��x��|3;�����\=ifJ���g����Z��HH�,׊D��G���DO�D*˖����G�^�"1��)�E޷�K0b��ʄ����L��|�2p:�+�2�}�B���+�fi���{G�Ɂ�2�5��%�����N�Bl8�s�oәy��4�_H
L�٩D��]�*)��2�������:�Y�H��V��F١PҭrG:������*հ�N]+ͣ�z��L�=nJAB,J[�7P(,=(��Ki�R�./fTR9n3]�99�.j�|D$:�Rf� �0Y���\tb30��M-��*��\�XJ�n��mV9��_�L�]_ۥ"߄6���]���a�-(Dv�����&�6�/�<[��Z�Tww�"{~���L�,Z�U��̒�5�f�5�U�4� �>�3,�{���R#oE^�#�|��)��ӧd���8��^��j�U�z}�����X��q]q��"� ��6�ko%
���fX}�1�fB@�2�	Od�|H�<�l�h�-���n��� �@���(SղT+���'��|��[��F�K�"?��/���|��s��?�Od/n����k��b�����ԗ�/��_���{���$����_IN��U|�����˩��0d�TqD���h&Y�w��A���)�6�.���Ԯ���4P�ϻ_^��C���0�y2��n�����ﷻN@Ϸ�uH~��\�
k#�F��Ͳ$����՞�mh�u����֋ ��1��s�@�*�pG#w�d]�5���Fl�]u�u	:�lG@�R��u(�!�{��.�B���� �)�� �OU\��y�L����}Wѻ �-4�~��΀�1	-Fr�C^a/��;tB��MZsf(�X�:u
9vy�t����ŗ<�}��� ���հo�	k��<�\�xH~��%�#=�	7�0< ���=����|c�[W�>ҰS�\5�	vV�s}j����̆�>j\��!х"ub��!?��z�@�La�'�O}�V,���`��y�����	������Kf��P���J�Ay'�̠ɸ���D�B ن��>��`�By���zP5���p"�r����5��Aܫ���9�q�qo`Nѱ�-	�^���(���}�T|ŻO~P@�y~	 ��������}���ƞ���ytz���{�9�<Zװ|��p���o~bH�1���7��ć����[
�f"OJt'��i>'	���е���3�p@i6x�OB�xl��9��6�%�w$k�سumpݍ�q-�@���S^2�\7N���]E\
���������pc���#�>Z���>��C���ԫ­eq���kNxH^6����W1Ho�m/!/O,t`2j�tۏ0���
���b8ᵐC��6���dg���iX[��#�d CÜ�I �8���Q��ݲa��X��hW�D��`W��l��X����wB��kcd�����ZviC$����/�+�\(���a�d�:Ձ�����nأ���5{g3�Ȇ[W��:زռI�⹷�d�dh�MQX*NW���� ����':$T�4!x@6��[�#��!I�&�<�!>9��N�!R��( �:�C��L�X�!f�B�X!@���∬B�9���m�׵%�):�(�Q��X�^K���<�4�h��n��$p���M(m�D�
�b��BG<�a�ڎ9zrc�R~��qK��؋Q �8_�:��v��j��}�ဿ���g^�����:�9��L����x*���ߋx��ч���H@�VɎ�K���GP��?6"ϣ̡	���u�aB�4ǜ��H���݋���䎂M�q�7з
A�h,��U���Y^(ߠ����� �WVt�w��@�
�Ǔ)�@N���
�q5��R�^O�SJ�O@�q�?K+r_�gS �Ȩ�N#�����}a���ӼXn�*�0�n�ǵxɇ0_����i/vH�0�P]>H*�TȲKdbi(�&z1� �R����eR5d�q��LVM�U
��
C>���o��s�7���m#5��G�3���7�7^x�S���.*�w�v�ߑ���J܌m��o@�.����O��B�?�ˏU�i�g�_a8��7��cغ�]��m
M���U�1^�&�n��W�/9�vE�rLYl��qhy��(��&�0���
��=���*hu&jN�f�u��5�E5��dLK�j�i�*v0:�2������E2�ѵ�����0��t�p��m��w/���+S.'yT�f���6xD��R8��|c����\�*�*����ǳ��f�c�p��P�����0��s��9�F���g[=���K��O!E^�z��s�%��KK�m㪹#X�XmJ�j%/N+�Ԯ6�Dػ�>���nV��:���L0Յ^c��E�A�e=<W�e�
|�?9FbX��?Ι�ހc�ȟ��rE�������C��0��$�+���z�<����L>��R/aajs�P�It�2���p���8��@����nb���[�|�z�=&��
~��+�D+��zcp�R[��#	$�|�ح��|W�Ķ��qDk"�!�8���(�*���Bё���NQ��m�����Y04ɻ>�E%���+kNۺ���;U����V]M�1��&��A�~�v�I��8���x�J�\�c����6�	���?8���?y����������'I��?
�������?������<����{�o��Q��?��*����  ����,�?���4E~���m�����?���%��_�OT��O������_���w$ p��_�@S�G������������_I�5
�ŤH�1����Rd�.�#?��
c^$�2��+��K�����zw~n��3<u��`�|���_���럋Ym�n�t�]��֞���}�ey9e$�c��M��w�t�e�sܨ[�=?��A�fzkz�6C&�;��#���g��a���3�O�_N��R5n{�8$��a�j�#�����O7�|W_i����u;<p��!�_>���{C�~���@q����3��Q �����P����V��?=���������'��(P1��:��~	>5����+�J�����G��i��Y"� �����9���y�����|�]�耊�����������( �:aU'���W�p���ԃ�O��@�_�C�_ ��������?��#����
�C��Q����"�k�s������Z;��EqX�Wm�s�bX(��e%󟡥l_�?��O�gf?o�V�z���m��x��gQ4�7�j�~~�����'�th��*��\f5�4�eu��z������t��T��sc��V�*��F�����2 �e�a�\j_��f�_������}��}?2�����^���E��q ������\1߲��1&�Kg�Y��=��s��尨���\��zb��YW\YK;C�PKv��E�6-��1Q��d9�?��aޗ�Q>�~�=�˃i��N83Ken�wK`����_0�O����n���C��2�����X����������O���O�����0�Y�@�U���s�?,�����W���Q +��M� p�����:���?������p��b��3�6Mg����v���ٯ��?��_����.���a=�Z}��kwBM���V�x�WWV�rg�_.A�\C����N*ւY+؎�IA�����}k����T9;2t��>oۖ�=���_��X���)�ןgTK��9�_(�S[�/e|⥎��2�{��}ǘ�&�ҭ�&LF�E{�ӛX�ƛ�|iM��b3�]od�t�T��_/R�U��x=1ՓF5� �YdH�������������G=��?�@�-�K�o1�� ��ϭ�p��������#N��Jg�$OE���ȑ�$1��a(��|^i&I&�C�����I��������C�����?+;��8�ʶWo�m�ȶ�x:��y���s*Z��5�'AS����b�nNl~
��q�y�n/��H��&1�w��rr�9�p���7�dAK�DO5m�鑽K���]=�f~��φ�����������P������[)p��!��X�?��T�����q�~1>!p����ï�������^;mƉ������xy'��e砇���-B΍���%��;��Gjҫ��o_2�-��v�g����n���c�eB����O[m8rk�U��f����������e�d��� �{+��i��V����#<�����8���Wu��/����/�����j�?�� �O��?�?xM�y�U�%�W��^��MU���z"t����yz��-*��/�������g�Um�f ���O�  �ճw \�j���P��% �� ���l����\�u�-c���$��aF�j��b����,\W�7�2�k��us"�QM��h�\H�U�9��d��"�H<灾'_��������� ΰ��r�J�7���$��ti_nՓ����H��*�C;V�5��hO����lvhf��<O 8��Rjjc����Q<>jZ%���7�oeKwTC��y8�u1:��P�M�fKI��L3:b������ݎ�*�X���;��/����j��|o��"9+6U_������x��(���cA�����������V�#�P4�� �O��?0��H�<��*��Q���������������`��" ���<�A@�")D~D�1����>ϳR,�"/ƌD�m>Cӑ(ŬS>��0��a�!���KA�	~e���������z�h�Kz4�ճf��ޏؒ�-v�p��_���]��.�[�k�1�yܷ�S���5�tw�8L�$�ϝ�z|�<dW������e���T���C�d���}+p��)����� �������g	�;�8����Y��(���w���C4��G�<�q�?���O�w�?��C��/߾�/��1*��Q�w���
���~������o��݌��%�+��v"�[}�r���ò��oM�_��uڞ?��}{�����[)�����;�~�9�q�Z�W{��G�<+�\�݁5�vN�=I��x��6'��A[im:��HX����o�fÏ�4�,��]���+������fR���@�X2�$n�\����v��D{C;��>x�QPE"�β0���ڍC��v��୔ns-����]ىl�C�pT63�P�d�1+��č��|����bw3#�F��H\��k�}������u��$�������dzQYI8E��/cݖ�8迫ڃ���������ϭ�p��b���"��h�8�����9��C����o����o�����8���2H`	��?��Á���_���ӗ��X���9
� �_���_������`���������y���'�� �G��&�����GT���������_=����P1��9D� ���������� �s�
��_9�s��@����`����G�x�@� ���W�p����]��?��!��ϭ������0�� 8����x�@� �� ������H��9D����s�?,����/�s��"���������?���?T�?�����,M���*@���������+���w$�����9p�����:@�?��C���:��)`��������e|���!��@�������w����p�������>��� 2�8�x��J,����b�!Ò�O��/����ϲ������/p��� �������1�F@�g�ӗ��ٺF��?E�J�,�[n�q�4�NG1�i]J�Ox]yD��$�����jhqX�MgC�}�Ve�8��3��;k�,�*���VW�Z';Z/N��p�U�G-��&�|�n��A��i?����x�h��cŚo-�khw���~�1�?�V����|U�J����_u������2`��Ͽ��kX���	��C�W~e���;���h�6��k�Y�����7���A���E���K�7���{tWvYg��}8̍(]5g6���}��F��s��ׇӣ��r>ݝ�򾷷�^��w�� �8j�͢7�9⿷���n�;���?����k�o �_0�U`��`�� �����h�*����~���A�}<^��'����OioG�:V�Ɲ8��$*�S������j����n�NS<�kR�`�Xo��cv��a����vZJ{�u[�]��-�%"-؏S��Ea�5OT���y���c3�'�_�e�K����%�$��-�~w�ۙ��Ľ�'_^����ѩ��g�P
K��J�7���N^���@���V=Iz��<�-�2?�c�\'�(��˸��f�fv?,ʖ�FK8ý�Y�M�I��bd�~�4"���ٛ�ǣTkv��)��џD��:�֠�d��k�$��dךp���g���f�	{�?���O���Ň﯀���4�r$����@C�	>���_��������X8$�!�����0����rt�/l�����������i�������(����}=��?���������$KC�^���U���W��>���f�
G���N4��Wگ��hh�������K�E�9�]�K�tE�w��,�R~�{�~�����9?�Г/5�"�>u�[J���R����͵��ֶd<�J~ɴ�׬��(ŭ��mog8
MuW����Ӊg��k]:�Mr���L��i��9���zY�(%K�ԮsJޡl~5nG�&�*��)%�r~�Rb1�������{ʾ�ӗr��z���L��ײ&�^�~��7�9���>�'"-qREU�ag:�35��o��~�)��}������s����Z��wY��nɚ�˩B�;�+*T¶9'8).�eo O&ҹ'������ں��H�tX���=Oɣ�
K�ϹS��^���e�y�Xr�ڪ���y�`�����?��"�'���L�XڗfLH�ׇY>�f�۞���,XF����!�q Q~L�T�����������?$������䖗�^��н�0���8��s��8c�sO�����˕o�
��rS+���V|�����}G��c(��� ���{��?$@�����@q�������?������:�-�����x��T�)㋭�	�»��?@���Ɨ�:���r������v?�gr������R�/���K��%�G�-��0i���-�ȫ|���zqc��c�'3�֔�]�F0m��5��Rs��0�5���r&���d�h'��k�ni?�y���� ��z�N��o�J��Ĳ�w~�����	u&�X���D ��}��pb���TQ�} ��Ӗ\N�l��{"lˀ�y�w�y,j��Ȑ����0�"�[V6��L�ք�g��@n����T?��SIŇ�h���P�2�jډC�T�lV�HC�^[jg�aA�j��9�E���|�4'�N���ZP�(3������ �������� ���Rh��t�\Ʊ�Q&�d�O��O�놪R
���2��b]�(��8/�˕t��D�q�����D���
~d��X�7���-�Rj��9T���nd?�j���w�y�f?��}Y�$��^�����~������cH
���@�_�����/���+I�/��K ��g�����R����i����`W�?CB��
�6��'���{�:*ˣM��k6�r��;�����p��Q��/����}O��2�cuӶ.&
ȇ"��V�B�U��K�خ����/��˪�E�м�\!�;tu�B���\����k	#q�Nֻ��:/��é^:-a`O�n�7�u��%fR0ܵ��j�qz��W�7���I\UI��7�p�7�
N�ʶ'wY�l��:o��`�m�[Bp��Kg[lt��Q8��ȷX6j��}�ߋd�5'�C�r�^��M�v؛kcWd&ֶa�rK3�m��K�֕U� �a�'[lK�5�i��K�^�MV����f_G��!Ge;o	�C�?dm֬ɲT��_�e�a�9F�0�X����1�{�[��~e��?�<�?���ߐ��
�h�5�������y���);�����?�"����IA�w*��O����O�����?����.�\����y���)�?������������S���������������y�����%�q��=�'1���A.�����ϔ��_��C�� ��g��7���7d��I�`�� ��Ϟ�	�*��J	Y�?�Bd�������1���r�������o����?R�?���?�/r�����P��
��P�= ��o���/]�?@�GJ��CEHv�E���@b���������`��_��|!������r��0��r����r�_�?��?���� �� ��l��o�?��O*�R��	�������������|�?��g�\����� ���!��~����0����+����C�� ��o���/�W�?���r��Mฎ�efA)Z�$z�B'5CY�2��LY�5��C�(��Ա
Ɣh���?�����/���?������/�㰨�f��_���������ҠEV��K<��9j��EJ�7��4}����Wª�q��_l�
��SQ���5���N���l2\=l9F�M��lT$��vTй�:$>^!m^_�Il��}��֔ښ���(�4�p��)Mo�f�7�r�3����W�?�{W'��������gvȪ��0�����/;��!�';d���|�������"��_v�����-Bډ�.1A��DL�U4ݟDm�\�:<���Μ.�_C�:�vg�ڨ������������G0ޯKeq��1�ZIC�c��+�H-���Zl����,���h��S��C��Z��/A�oFȲ�הG��/�_������� �_P��_P��?��2���!r��(�Z�Q����W����_�������t��Qے�����뿏�X�Dn.ឺ�>Ӂ����6�eo��,�r���aTg0�;�6p'�:^tTgZd�q��F4)n� 3ȩ�z�X���t�m`J�ض���+)=eW-��ߥ��R�r�K���9�?��"�V�œ����m2}�D��U�����F��W�'-8<�Q,�|���P����J��R�!/4�k>��gO�����I���B�:���Mu�F��8�ʡ�#�X>� ������=h�G$����;�t��$L��
�o���%��p
�����n��7�d��"�����?�F�G��?R@.���Q�� ��������K�?h��?���O`W��b(��4�)�'E`Y_�;�?����ߨ����T�9���<�kq� ��Ϝ������
�����>���o��i��H������x�ȅ��o����K��?�2S@���/��?d���?L��	r��������������c�����a`s]nrlLJ/���C�[��Eb��#��j?��
��jWO�ɏ!��#)�@^Q�;mq�K�o�R�{��@^W��+����N�Xcv4O׋U����R���d�XT6x���duV+��;��F��Fյ����0'٠lLNӍX7m٫���_�{�~/e�ȍ�_EN�cQ�fG�T��E�	�ݲ�y8Vg���&�<[��r���q՝J*>�F��ǆ��!W��oM�R�^�Y�"i�{m�����������֋�Ӝ��:�jrk=@���X���0ȅ����̐��{1	x�����}�\�?��g�<���G�H���o�0��
�����������I���뿏��g})��߷���S�F����: ~6r�C�f�Z�_�&��/��ۉۨY!;��<���ak:����E��G�d^�'�{m�_k���R��G5 ��>� ���V��>�u
a5�rU�P�q��y��Z�2k��ʔz�"r�w�x��΂��*�-���C�DG�-?Жk��/�  I���@�"�?��Gl�ges�X���=\f��p��t�v��bˌ�h�Ae��XE��2G�M[��P�m��+rw��V�J�E՘�v�Z�/�7r�����W*�\�}�<�+q������_�����,�����?Y!M)1�A+�R)+�����Aa*M�8E��+:�k�0�aP��2�^)3Ă��?�������5�'����9�琙3�t�js6��2���o+�r��y�S7V�>+������ѝhco5�W?2��	�w�j�F�%G�g����/���l��iԭ��AN�I�GS�0|���c[��)���Z�����i��L���s����/;��!�'3d��ϓ �a`֗�.����/;���ϛ��k)�]�Ρ��+R�,��3h7C�M�f��Ev��^�?z���h�%<ϫ����!�(��ƄB��8��+��F�ű�v������#��0x����;n�u`LI@��Z��������4�y��)0p��E��e����/����/����e�h�l��GQ%��k�o��?��������g�5P��-'�h�9W)�y��\�#����  �� ^� Wf�S�n�W�m�+֍(h�띢j+K�Ǖ6˧
�BK�r^f�#M���ڔ:�bed�(��м�������v����V�Oe��<Na�Z�Y�qO�*7���F56J���D.j�� �
t�'��G�Q�+�%'��� �*z�:�[
�)KSҮ�aR?����Q��0~hV�i}��ԧBz&�>�[~ԋ�gƁ���*��_��mO�xf,��Y�ub�����6���fg�l"$Oi�U�U¦E���^h����6js����>^�U���`�f���(t՝�^<��׵�_�����'�O�4����ssn�N!���J���w��6��Ge3��s�� �\_������k��v'U�]xHv����a�����t�RA�&����]ȭ]mUx��|=����j����[����ˮx_��y���r��ya��.��j��yI>_П�׾��[�Ok��~�+�8M��A�jx�S���UmU��B����\�`�~t�w�<�v�^'o�Fq�#�a�A��ߩꡮū���N>�|a�|��v����d�dϒ���������xۏ�v�#R���޼�GA[��O_|��7���:�>/�/���)������^�E�)�+���������ێ��m�wa�HB �u��z{��m��u������y��Er��_W������k}a�~��:B���vśَ�Ļw��
���s�1������;vz�SB����Pn	���ݿ׊����ۨ��?��Yn��o���	ֺ�}qm|tg�=��g�<�s|�V�t��]��_�O�/���.���1���91'��C�>^<��2�"��`��|��+��$?9�����;}�}W��[�.�i�����]DR���<�]��/%�yՅY&���~~���`�?>���w�F            �s�24  � 