/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.json.JSONObject;
import javax.servlet.RequestDispatcher;
import tools.InvalidCaptcha;

/**
 *
 * @author Kimberly
 */
public class CaptchaServlet extends HttpServlet {

    private static final String SECRET_KEY="6LfR17osAAAAAB1AeqL1s9SFiyAab9rs8br8Ks2m";

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, InvalidCaptcha {
            
        String username = request.getParameter("username");                
        String password = request.getParameter("password");
        String captcha = request.getParameter("g-recaptcha-response");

        boolean isValid = verifyCaptcha(captcha);
        
        request.setAttribute("captcha",Boolean.toString(isValid));
        if (isValid){
            RequestDispatcher rd = request.getRequestDispatcher("/home");
            rd.forward(request, response);
        }
        else{
            throw new InvalidCaptcha("Incorrect Captcha Verification");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if(session!=null){
            session.invalidate();
        }
        response.sendRedirect("login");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private boolean verifyCaptcha(String gRecaptchaResponse) throws IOException {
        String url = "https://www.google.com/recaptcha/api/siteverify";
        String params = "secret=" + SECRET_KEY +"&response=" + gRecaptchaResponse;
        //creates connection
        HttpURLConnection con = (HttpURLConnection) new URL(url).openConnection();
        con.setRequestMethod("POST");
        con.setDoOutput(true);
        //sends connection
        try (OutputStream os = con.getOutputStream()) {
            os.write(params.getBytes());
        }
        
        
        BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
        StringBuilder response = new StringBuilder();
        String inputLine;
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();
        JSONObject jsonResponse = new JSONObject(response.toString());
        return jsonResponse.getBoolean("success");
    }
}
