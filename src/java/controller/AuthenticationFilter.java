/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controller;

import java.io.IOException;
import java.sql.Connection;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;

// This annotation maps the filter to intercept everything under the secure /app/ folder
@WebFilter("/app/*")
public class AuthenticationFilter implements Filter {

    private Connection conn;

    private List<String> excludedList;
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        String paths = filterConfig.getInitParameter("excludedPaths");
    
        if (paths != null) {
            // 2. Split the string by commas and parse it into an array list
            excludedList = Arrays.asList(paths.split(","));
        } else {
            excludedList = new ArrayList<>();
        }

        // Optional: Log it to the GlassFish server console to verify it loaded
        System.out.println("AuthenticationFilter initialized. Allowed paths: " + excludedList);
    }
    

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        // 1. Prevent browser caching of secure pages
        httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
        httpResponse.setHeader("Pragma", "no-cache"); // HTTP 1.0
        httpResponse.setDateHeader("Expires", 0); // Proxies
        
        HttpSession session = httpRequest.getSession(false);
        
        // 2. CHANGED: Check for "currentUser" instead of "uname"
        boolean loggedIn = (session != null && session.getAttribute("currentUser") != null);
        
        if (loggedIn) {
            // User is authenticated! Pass the request down the chain
            chain.doFilter(request, response);
        } else {
            // Not authenticated. Kick back to index.jsp
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/index.jsp");
        }
    }
    @Override
    public void destroy(){

    }

}
