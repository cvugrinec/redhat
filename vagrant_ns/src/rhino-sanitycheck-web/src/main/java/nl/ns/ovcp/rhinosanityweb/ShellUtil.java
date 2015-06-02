package nl.ns.ovcp.rhinosanityweb;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.logging.Logger;

public class ShellUtil {

    private static final Logger logger = Logger.getLogger("nl.ns.ovcp.rhinosanity.util.ShellUtil");

    public static StringBuffer executeShell(String command) throws ShellUtilException {
        StringBuffer result = new StringBuffer();
        Process proc = null;
        try {
            proc = Runtime.getRuntime().exec(command);
            BufferedReader read = new BufferedReader(new InputStreamReader(proc.getInputStream()));
            try {
                proc.waitFor();
            } catch (InterruptedException e) {
                logger.severe("Interupt exception occured during shell exec of "+command+" msg: "+e.getMessage());
            }
            for (; read.ready();
                 result.append(read.readLine())) {
                logger.info("waiting");
            }
        } catch (IOException e) {
            logger.severe("io exception occured during shell exec of "+command+" msg: "+e.getMessage());
        } catch(Exception e){
            if(proc!=null){
                throw new ShellUtilException(proc.exitValue());
            }
        }

        /*
        if(proc.exitValue()!=0){
            throw new ShellUtilException(proc.exitValue());
        }
        */
        return result;
    }

}