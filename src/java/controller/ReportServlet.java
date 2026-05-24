package controller;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ReportServlet", urlPatterns = {"/generateReport"})
public class ReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Generate the dynamic timestamp using LocalDateTime
        LocalDateTime now = LocalDateTime.now();
        
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
        String timestamp = now.format(formatter);
        
        String filename = "COURSELIST_" + timestamp + ".pdf";

        // 2. Set the exact HTTP Response Headers required by the rubric
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
        
        try {
            // Document document = new Document(PageSize.A4.rotate());
            // PdfWriter.getInstance(document, response.getOutputStream());
            // document.open();
            
            // ... (Member 2 Derby/MySQL Database Loops) ...
            
            // document.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            // Route to Member 4 custom general error page
            request.setAttribute("errorMessage", "Error generating the requested PDF report.");
            request.getRequestDispatcher("/general_error.jsp").forward(request, response);
        }
    }
}