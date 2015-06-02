package nl.ns.ovcp.rhinosanity.util;

public class ShellUtilException extends Throwable {

    private final int errorCode;


    public ShellUtilException(int errorCode) {
        this.errorCode = errorCode;
    }

    public int getErrorCode() {
        return errorCode;
    }

}
