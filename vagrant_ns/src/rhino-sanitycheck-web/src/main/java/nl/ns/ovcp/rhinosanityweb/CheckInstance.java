package nl.ns.ovcp.rhinosanityweb;

import java.io.IOException;
import java.util.logging.Logger;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


@WebServlet(name="CheckInstanceServlet", urlPatterns={"/checkinstance"})
public class CheckInstance extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final Logger logger = Logger.getLogger("nl.ns.ovcp.rhinosanityweb.CheckInstance");

    @Override
    protected void doGet(
   
        HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	//	Create json file (will be parsed in check.jsp)
    	String instance = request.getParameter("instance");
        try {
        	logger.info("Executing check script for instance: "+instance);
			ShellUtil.executeShell("/opt/ns/scripts/checkEap.sh "+instance);
		} catch (ShellUtilException e) {
			e.printStackTrace();
		}
    	request.getRequestDispatcher("/check.jsp?instance="+instance).forward(request, response);
    }
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
	}

}
