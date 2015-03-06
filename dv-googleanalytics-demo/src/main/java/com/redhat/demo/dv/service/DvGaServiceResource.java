package com.redhat.demo.dv.service;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.json.simple.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;

import com.google.api.client.http.GenericUrl;

@Controller
@Path(DvGaServiceResource.DVGADEMO_URL)
public class DvGaServiceResource {
	public static final String DVGADEMO_URL = "/ga";

	@Autowired
	DvGaService service;

	@GET
	@Produces({ MediaType.APPLICATION_JSON })
	@Path("dvstats")
	public JSONObject getDvStats() throws Exception {

		return service.doDvAnalyticsCall();
	}

	@GET
	@Produces({ MediaType.TEXT_HTML})
	@Path("getRedirectUrl")
	public String getRedirectUrl(HttpServletRequest req) throws Exception {
		GenericUrl url = new GenericUrl(req.getRequestURL().toString());
		url.setRawPath("/oauth2callback");
		return url.build();
	}

	@POST
	@Produces({ MediaType.TEXT_PLAIN })
	@Path("dvstats/{host}}")
	public String getDvStatsForHost(@PathParam("host") String host) {
		return null;
	}

}
