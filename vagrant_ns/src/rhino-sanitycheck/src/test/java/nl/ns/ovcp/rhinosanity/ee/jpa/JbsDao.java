
package nl.ns.ovcp.rhinosanity.ee.jpa;

import java.util.Collection;
import javax.persistence.*;

import nl.ns.ovcp.rhinosanity.ee.model.Hsmreference;

public class JbsDao {
    private static EntityManager em;

    private static EntityManager getEm() {
        if (em == null) {
            EntityManagerFactory factory = Persistence.createEntityManagerFactory("jbs-ee");
            em = factory.createEntityManager();
        }
        return em;
    }

    public static Collection<Hsmreference> getHsmReferences() {
        return getEm().createNamedQuery("Hsmreference.findAll", Hsmreference.class).getResultList();
    }
}
