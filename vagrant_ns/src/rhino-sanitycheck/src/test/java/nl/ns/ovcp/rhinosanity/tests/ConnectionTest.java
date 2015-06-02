package nl.ns.ovcp.rhinosanity.tests;


import static org.junit.Assert.assertTrue;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class ConnectionTest {

    private static EntityManager em;

    @Before
    public void init() {

        if (em == null) {
            EntityManagerFactory factory = Persistence.createEntityManagerFactory("jbs-ee");
            em = factory.createEntityManager();
        }
    }


    @Test
    public void testConnection() {
        assertTrue(em.isOpen());
    }


    @After
    public void close() {
        if (em != null && em.isOpen())
            em.close();
    }

}
