package nl.ns.ovcp.rhinosanity.tests;



import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;

import nl.ns.ovcp.rhinosanity.ee.jpa.JbsDao;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.io.File;
import java.util.*;

import nl.ns.ovcp.rhinosanity.ee.model.Hsmreference;
import nl.ns.ovcp.rhinosanity.util.*;
import org.junit.Assert;

public class SmTegelTest {

    private static EntityManager em;
    private Collection<Hsmreference> keysFromHsm;
    private ArrayList<String> hsmFilenamesFromDB;
    private ArrayList<String> hsmObjectLabelsFromDB;

    @Before
    public void init() throws ShellUtilException {
        if (em == null) {
            EntityManagerFactory factory = Persistence.createEntityManagerFactory("jbs-ee");
            em = factory.createEntityManager();
        }
        keysFromHsm = nl.ns.ovcp.rhinosanity.util.HsmUtils.getKeysFromHSM();
        Collection<Hsmreference> keysFromDB = JbsDao.getHsmReferences();
        hsmFilenamesFromDB = HsmUtils.extractHsmFilenamesFromDB(keysFromDB);
        hsmObjectLabelsFromDB = HsmUtils.extractHsmObjectLabelsFromDB(keysFromDB);
    }

    @Test
    public void isCryptoStuffInstalled() {
        String expectedNfastDirectory = "/opt/nfast/";
        File nfastDir = new File(expectedNfastDirectory);
        Assert.assertTrue((new StringBuilder()).append(expectedNfastDirectory).append(" not found on this server ").toString(), nfastDir.exists());
    }

    @Test
    public void isCorrectJavaInstalled()
            throws ShellUtilException {
        String expectedSymlink = "/opt/java_sm/";
        File javaSmSymlink = new File(expectedSymlink);
        Assert.assertTrue((new StringBuilder()).append(expectedSymlink).append(" not found on this server ").toString(), javaSmSymlink.exists());
        StringBuffer sb = ShellUtil.executeShell("/opt/ns/scripts/showOpenJdkVersion.sh");
        Assert.assertTrue("OpenJDK 64-Bit version not found ", sb.toString().contains("OpenJDK"));
        Assert.assertTrue("OpenJDK version 1.7 not found ", sb.toString().contains("1.7.0"));
        sb = ShellUtil.executeShell("ls -sh /opt/java_sm/lib/ext/sunpkcs11.jar | awk ' { print $1 } '");
        Assert.assertTrue("expected /opt/java_sm/lib/ext/sunpkcs11.jar should be 516K ", sb.toString().contains("516K"));
    }

    @Test
    public void testAreHSMKeysInDatabase() {
        ArrayList<String> notFoundObjectLabels = new ArrayList<String>();
        ArrayList<String> notFoundFileNames = new ArrayList<String>();
        ArrayList<String> foundObjectLabels = new ArrayList<String>();
        ArrayList<String> foundFileNames = new ArrayList<String>();

        for(Hsmreference hsmRef : keysFromHsm ){
            if (!hsmFilenamesFromDB.contains(hsmRef.getFilename()))
                notFoundFileNames.add(hsmRef.getFilename());
            else
                foundFileNames.add(hsmRef.getFilename());
            if (!hsmObjectLabelsFromDB.contains(hsmRef.getHsmobjectlabel()))
                notFoundObjectLabels.add(hsmRef.getHsmobjectlabel());
            else
                foundObjectLabels.add(hsmRef.getHsmobjectlabel());
        }

        System.out.println("==============================");
        System.out.println("Found hsm filesname in DB");
        System.out.println("==============================");
        String foundObjectFileName;
        for (Iterator i$ = foundFileNames.iterator(); i$.hasNext();
             System.out.println(foundObjectFileName))
            foundObjectFileName = (String) i$.next();

        System.out.println("==============================");
        System.out.println("Found objectLabels in DB");
        System.out.println("==============================");
        String foundOnbjectLabel;
        for (Iterator i$ = foundObjectLabels.iterator(); i$.hasNext(); System.out.println(foundOnbjectLabel))
            foundOnbjectLabel = (String) i$.next();

        System.out.println("==============================");
        System.out.println("NOT Found hsm filesname in DB");
        System.out.println("==============================");
        String notFoundObjectFileName;
        for (Iterator i$ = notFoundFileNames.iterator(); i$.hasNext(); System.out.println(notFoundObjectFileName))
            notFoundObjectFileName = (String) i$.next();

        System.out.println("==============================");
        System.out.println("NOT Found objectLabels in DB");
        System.out.println("==============================");
        String notFoundOnbjectLabel;
        for (Iterator i$ = notFoundObjectLabels.iterator(); i$.hasNext(); System.out.println(notFoundOnbjectLabel))
            notFoundOnbjectLabel = (String) i$.next();

    }

    @After
    public void close() {
        if (em != null && em.isOpen())
            em.close();
    }

}
