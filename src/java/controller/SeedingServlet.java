package controller;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import tools.DataSeeder;

public class SeedingServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        
        // 1. Grab the Context
        ServletContext context = getServletContext();
        
        // 2. Fetch ONLY the cryptography parameters from web.xml
        String secretKey = context.getInitParameter("secretKey");
        String algo = context.getInitParameter("cipherAlgorithm");
        String mode = context.getInitParameter("cipherMode");
        String padding = context.getInitParameter("cipherPadding");

        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html><head><title>Database Seeder</title></head><body>");
            out.println("<h2>Initializing Derby Database Seeding...</h2>");
            
            // 3. Call the DataSeeder utility (DB credentials are handled by JNDI now!)
            String resultMessage = DataSeeder.seedDatabase(secretKey, algo, mode, padding);
            
            out.println("<h3>Result: " + resultMessage + "</h3>");
            out.println("<a href='login.jsp'>Go to Login Page</a>");
            out.println("</body></html>");
        }
    }
}