package com.redhat.demo.dv.service.test;

import org.json.simple.JSONObject;
import org.junit.Assert;
import org.testng.annotations.Test;

import com.redhat.demo.dv.service.DvGaService;

public class TestGoogleAnalyticsQuery {

	@Test
	public void testDvDaService() throws Exception{
		DvGaService dvgas = new DvGaService();
		JSONObject result = dvgas.doDvAnalyticsCall();
		Assert.assertNotNull(result);
	}
	
}
