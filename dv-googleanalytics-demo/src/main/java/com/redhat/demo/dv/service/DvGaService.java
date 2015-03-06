package com.redhat.demo.dv.service;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.springframework.stereotype.Service;

import com.google.api.client.auth.oauth2.Credential;
import com.google.api.client.googleapis.auth.oauth2.GoogleCredential;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.googleapis.json.GoogleJsonResponseException;
import com.google.api.client.http.HttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.jackson2.JacksonFactory;
import com.google.api.client.util.store.FileDataStoreFactory;
import com.google.api.services.analytics.Analytics;
import com.google.api.services.analytics.AnalyticsScopes;
import com.google.api.services.analytics.model.Accounts;
import com.google.api.services.analytics.model.GaData;
import com.google.api.services.analytics.model.Profiles;
import com.google.api.services.analytics.model.Webproperties;


@Service
public class DvGaService {

	//private static FileDataStoreFactory dataStoreFactory = new FileDataStoreFactory(DATA_STORE_DIR) // Use this when using the json auth)
	//private static final java.io.File DATA_STORE_DIR = new java.io.File(System.getProperty("user.home"), ".store/analytics_sample");
	private static final String APPLICATION_NAME = "swift-library-866";
	private static HttpTransport httpTransport;
	private Log log = LogFactory.getLog(DvGaService.class);
	private static final JsonFactory JSON_FACTORY = JacksonFactory.getDefaultInstance();
	SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
	Date today = new Date();
	
	public JSONObject doDvAnalyticsCall() throws Exception {
		
		JSONObject result = new JSONObject();
		
		try {
			httpTransport = GoogleNetHttpTransport.newTrustedTransport();
			Credential credential = authorize();
			Analytics analytics = new Analytics.Builder(httpTransport, JSON_FACTORY, credential).setApplicationName(APPLICATION_NAME).build();			

			String profileId = getFirstProfileId(analytics);
			GaData gaData = executeDataQuery(analytics, profileId);
			result = getGaData(gaData);
		} catch (GoogleJsonResponseException e) {
			log.error("There was a service error: " + e.getDetails().getCode()+ " : " + e.getDetails().getMessage());
		}
		return result;
	}
	
	
	/* authorize via json file
	private Credential authorize() throws Exception {

		InputStream inputStream = new FileInputStream("/tmp/client_secrets.json");
		GoogleClientSecrets clientSecrets = GoogleClientSecrets.load(JSON_FACTORY,new InputStreamReader(inputStream));

		// 	set up authorization code flow
		// 	by adding the access_type=offline ...
		//	you have the behaviour of a refresh token, thus long lived token
		GoogleAuthorizationCodeFlow flow = new GoogleAuthorizationCodeFlow.Builder(
				httpTransport, JSON_FACTORY, clientSecrets,
				Collections.singleton(AnalyticsScopes.ANALYTICS_READONLY))
				.setDataStoreFactory(dataStoreFactory).setAccessType("offline").build();

		// authorize
		LocalServerReceiver lr = new LocalServerReceiver();
		AuthorizationCodeInstalledApp acia = new AuthorizationCodeInstalledApp(flow, lr);
		Credential result = acia.authorize("user");
		return result;
	}
	*/
	
	//	Authorization using P12 key
	private Credential authorize() throws Exception {

		String emailAddress = "1035347952851-ntev3gf8k26ntp34vqm9lvik5cut8k3m@developer.gserviceaccount.com";
		JsonFactory JSON_FACTORY = JacksonFactory.getDefaultInstance();
		HttpTransport httpTransport = GoogleNetHttpTransport.newTrustedTransport();
		GoogleCredential credential = new GoogleCredential.Builder()
		    .setTransport(httpTransport)
		    .setJsonFactory(JSON_FACTORY)
		    .setServiceAccountId(emailAddress)
		    .setServiceAccountUser("chrisvugrinec@gmail.com")  // Depending on the Google API setup this setting needs to be set...or NOT
		    .setServiceAccountPrivateKeyFromP12File(new File("/Users/chris/Documents/workspace_igopost/dv-googleanalytics-demo/keys/datalinks-website.p12"))
		    .setServiceAccountScopes(Collections.singleton(AnalyticsScopes.ANALYTICS_READONLY))
		    .build();
		return credential;
		
	}
	
	private String getFirstProfileId(Analytics analytics) throws IOException,GoogleAnalyticsException {
		String profileId = null;

		// Query accounts collection.
		Accounts accounts = analytics.management().accounts().list().execute();

		if (accounts.getItems().isEmpty()) {
			throw new GoogleAnalyticsException("No accounts found");
		} else {
			String firstAccountId = accounts.getItems().get(0).getId();

			// Query webproperties collection.
			Webproperties webproperties = analytics.management().webproperties().list(firstAccountId).execute();

			if (webproperties.getItems().isEmpty()) {
				throw new GoogleAnalyticsException("No Webproperties found");
			} else {
				String firstWebpropertyId = webproperties.getItems().get(0).getId();
				log.info("firstWebpropertyId " + firstWebpropertyId);

				// Query profiles collection.
				Profiles profiles = analytics.management().profiles().list(firstAccountId, firstWebpropertyId).execute();

				if (profiles.getItems().isEmpty()) {
					throw new GoogleAnalyticsException("No profiles found");
				} else {
					profileId = profiles.getItems().get(0).getId();
				}
			}
		}
		return profileId;
	}

	private GaData executeDataQuery(Analytics analytics, String profileId) throws IOException {

		Calendar calendar = Calendar.getInstance();
		calendar.add(Calendar.DATE, -365);
	    Date yesterday = calendar.getTime();

		return analytics
				.data()
				.ga()
				.get("ga:" + profileId, // Table Id. ga: + profile id.
						dateFormat.format(yesterday), // Start date.
						dateFormat.format(today), // End date.
						"ga:visits")
				// Metrics.
				.setDimensions(
						"ga:source,ga:keyword,ga:browser,ga:city,ga:date")
				.setSort("-ga:date").execute();
				// .setFilters("ga:medium==organic")
				//.setMaxResults(100).execute();
	}

	@SuppressWarnings("unchecked")
	private JSONObject getGaData(GaData results) {
		
		JSONObject result = new JSONObject();
		JSONObject rootResult = new JSONObject();

		JSONArray list = new JSONArray();
		
		log.debug("printing results for profile: "+ results.getProfileInfo().getProfileName());
		if (results.getRows() == null || results.getRows().isEmpty()) {
			log.info("No results Found.");
		} else {
			

			// Print actual data.
			for (List<String> row : results.getRows()) {
				JSONObject subObject = new JSONObject();				
				int counter=0;
				for (String column : row) {
					counter++;
					if(counter==1)
						subObject.put("source", column);
					if(counter==2)
						subObject.put("keyword", column);
					if(counter==3)
						subObject.put("browser", column);
					if(counter==4)
						subObject.put("city", column);
					if(counter==5)
						subObject.put("date", column);
					if(counter==6)
						subObject.put("count", column);
				}
				list.add(subObject);
			}
			result.put("results", list);
			rootResult.put("Root", result);
		}
		return rootResult;
		
	}

}
