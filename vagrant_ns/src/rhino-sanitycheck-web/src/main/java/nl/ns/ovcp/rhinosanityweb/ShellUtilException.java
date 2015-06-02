package nl.ns.ovcp.rhinosanityweb;

public class ShellUtilException extends Exception {
    private final int errorCode;


    public ShellUtilException(int errorCode) {
        this.errorCode = errorCode;
    }

    public int getErrorCode() {
        return errorCode;
    }
}
