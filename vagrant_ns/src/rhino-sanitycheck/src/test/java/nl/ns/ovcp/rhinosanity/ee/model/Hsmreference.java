package nl.ns.ovcp.rhinosanity.ee.model;


import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.NamedQuery;
import java.io.Serializable;
import java.sql.Timestamp;

@Entity
@NamedQuery(name = "Hsmreference.findAll", query = "SELECT h FROM Hsmreference h")
public class Hsmreference implements Serializable {


    @Id
    private long id;

    private String filename;

    private String hsmobjectlabel;

    private Timestamp importtimestamp;

    public Hsmreference() {
    }

    public long getId() {
        return this.id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getFilename() {
        return this.filename;
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }

    public String getHsmobjectlabel() {
        return this.hsmobjectlabel;
    }

    public void setHsmobjectlabel(String hsmobjectlabel) {
        this.hsmobjectlabel = hsmobjectlabel;
    }

    public Timestamp getImporttimestamp() {
        return this.importtimestamp;
    }

    public void setImporttimestamp(Timestamp importtimestamp) {
        this.importtimestamp = importtimestamp;
    }

}
