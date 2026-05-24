package controller;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// Importing your specific DAOs from the tools package
import tools.UserDAO;
import tools.CertDAO;
import tools.ExamDAO;

@WebServlet(name = "ConnectionTestServlet", urlPatterns = {"/test"})
public class ConnectionTestServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html><head><title>System Diagnostics</title>");
            out.println("<style>body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f4f9; }");
            out.println(".card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 600px; }");
            out.println(".success { color: #155724; background-color: #d4edda; padding: 10px; border-radius: 4px; margin-bottom: 10px; border: 1px solid #c3e6cb; }");
            out.println(".error { color: #721c24; background-color: #f8d7da; padding: 10px; border-radius: 4px; margin-bottom: 10px; border: 1px solid #f5c6cb; }");
            out.println("</style></head><body>");
            
            out.println("<div class='card'>");
            out.println("<h2>DAO Health Diagnostics</h2>");
            out.println("<p>Testing actual DAO object instantiation and JNDI pooling...</p><hr>");

            // 1. Test UserDAO (Derby)
            UserDAO userDao = new UserDAO();
            if (userDao.testConnection()) {
                out.println("<div class='success'>✅ <strong>tools.UserDAO (Derby):</strong> Online and connected.</div>");
            } else {
                out.println("<div class='error'>❌ <strong>tools.UserDAO (Derby):</strong> Connection Failed. Check server logs.</div>");
            }

            // 2. Test CertDAO (MySQL)
            CertDAO certDao = new CertDAO();
            if (certDao.testConnection()) {
                out.println("<div class='success'>✅ <strong>tools.CertDAO (MySQL):</strong> Online and connected.</div>");
            } else {
                out.println("<div class='error'>❌ <strong>tools.CertDAO (MySQL):</strong> Connection Failed. Check server logs.</div>");
            }

            // 3. Test ExamDAO (PostgreSQL)
            ExamDAO examDao = new ExamDAO();
            if (examDao.testConnection()) {
                out.println("<div class='success'>✅ <strong>tools.ExamDAO (PostgreSQL):</strong> Online and connected.</div>");
            } else {
                out.println("<div class='error'>❌ <strong>tools.ExamDAO (PostgreSQL):</strong> Connection Failed. Check server logs.</div>");
            }

            out.println("<hr>");
            out.println("<p><em>If all three DAOs report green, your backend Java logic is fully wired to GlassFish.</em></p>");
            out.println("</div></body></html>");
        }
    }
}