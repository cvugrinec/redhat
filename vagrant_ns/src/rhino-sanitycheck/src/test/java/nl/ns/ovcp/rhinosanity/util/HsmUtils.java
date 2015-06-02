package nl.ns.ovcp.rhinosanity.util;

import java.util.*;

import nl.ns.ovcp.rhinosanity.ee.model.Hsmreference;


public class HsmUtils {

    public static Collection<Hsmreference> getKeysFromHSM() throws ShellUtilException {
        StringBuffer sb;
        if (System.getProperty("file.separator").equals("/")) {
            sb = ShellUtil.executeShell("/opt/ns/scripts/getHsmKeys.sh");
        } else {
            sb = new StringBuffer();
            String testKeys = "key_pkcs11_uc0fa05e61bf82136370edb6483f643545d53bbaea-0cf6ae6a9630da942e6e647ca17a8ed2a6ae841b,TSTMKCPSRSANSH000_0F10D8$key_pkcs11_uc0fa05e61bf82136370edb6483f643545d53bbaea-0d5967beabdfeb90ab0dc7f5ab11f2ecd6dcafd9,TSTMKCRSRSANSR000_031073$key_pkcs11_uc0fa05e61bf82136370edb6483f643545d53bbaea-0d83213b18600bb9395b1abb09112a1e144cd6d4,crenckey$key_pkcs11_uc0fa05e61bf82136370edb6483f643545d53bbaea-10969207259c79f8cccad46dabf8d949a8ab0306,TSTMKCPSRSANSR000_0F10D7$key_pkcs11_uc0fa05e61bf82136370edb6483f643545d53bbaea-12ce46c613581c8436b81e74e5f8fe4e800555e5,TSTMKSPSRSANSP000_0E111F$key_pkcs11_uc0fa05e61bf82136370edb6483f643545d53bbaea-544f03c7c3f9adf4f993f69ad3dd52eb18668c1a,kek2$key_pkcs11_uc0fa05e61bf82136370edb6483f643545d53bbaea-801e48d728fd4a7d2ce1696c459ff37d350f2323,TSTMKSPSRSANSH000_0E111E$key_pkcs11_uc0fa05e61bf82136370edb6483f643545d53bbaea-85708dda00dd456206e97f3783c53118bd662e58,TSTMKCRSRSANSH000_031074$key_pkcs11_uc0fa05e61bf82136370edb6483f643545d53bbaea-b072ed4a21a4e74558de59cdcee241fc31350cc1,tstiks9yupltls000_NSRSC$key_pkcs11_uc0fa05e61bf82136370edb6483f643545d53bbaea-b7363e6b276fa140d43b05e23555b418a04da943,tstiks9ydwntls000_NSRSC$key_pkcs11_uc0fa05e61bf82136370edb6483f643545d53bbaea-be54460c3d87150fe3b79b8a29809324fed1ec35,tstikmfctransr000$key_pkcs11_uc0fa05e61bf82136370edb6483f643545d53bbaea-c1bb0835af56ece4f9d2079ddf03f578dd2d3ae9,kek1$key_pkcs11_uc0fa05e61bf82136370edb6483f643545d53bbaea-c5bb6eb29555a50987ef494ade72c7dab7650465,TSTMKCPSRSANSP000_0F10D9$key_pkcs11_uc0fa05e61bf82136370edb6483f643545d53bbaea-e7c4a1708e81d5fbe467a0e018abfabba1b40f86,TSTMKCRSRSANSP000_031075$key_pkcs11_uc0fa05e61bf82136370edb6483f643545d53bbaea-f59dee93d0233d79607b035caa2fb603e46af327,TSTMKSPSRSANSR000_0E111D$";
            sb.append(testKeys);
        }
        Collection<Hsmreference> keysFromHSM = new ArrayList<Hsmreference>();
        int lastCharacterFoundAt = 0;
        for (int i = 0; i < sb.length(); i++)
            if (sb.charAt(i) == '$') {
                String regel = sb.substring(lastCharacterFoundAt, i);
                String elementen[] = regel.split(",");
                Hsmreference element = new Hsmreference();
                element.setFilename(elementen[0]);
                element.setHsmobjectlabel(elementen[1]);
                keysFromHSM.add(element);
                lastCharacterFoundAt = i + 1;
            }

        return keysFromHSM;
    }

    public static ArrayList<String> extractHsmObjectLabelsFromDB(Collection hsmObjectRefsFromDBParam) {
        ArrayList<String> result = new ArrayList<String>();
        Hsmreference hsmRefFromDB;

        for (Iterator i$ = hsmObjectRefsFromDBParam.iterator(); i$.hasNext();
             result.add(hsmRefFromDB.getHsmobjectlabel()))
             hsmRefFromDB = (Hsmreference) i$.next();

        return result;
    }

    public static ArrayList<String> extractHsmFilenamesFromDB(Collection hsmObjectRefsFromDBParam) {
        ArrayList<String> result = new ArrayList<String>();
        Hsmreference hsmRefFromDB;
        for (Iterator i$ = hsmObjectRefsFromDBParam.iterator(); i$.hasNext(); result.add(hsmRefFromDB.getFilename()))
            hsmRefFromDB = (Hsmreference) i$.next();

        return result;
    }


}