package controller;

import com.itextpdf.text.Document;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import tools.UserDAO;

@WebServlet(name = "AdminReportServlet", urlPatterns = {"/generateAdminReport"})
public class AdminReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Security check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("uname") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        String activeUser = (String) session.getAttribute("uname");

        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
        String timestamp = now.format(formatter);
        String filename = "USERLIST_" + timestamp + ".pdf";

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        try {
            // Initialize Document in Landscape mode
            Document document = new Document(PageSize.A4.rotate());
            PdfWriter.getInstance(document, response.getOutputStream());
            
            document.open();
            
            // Add Company Header
            document.add(new Paragraph("Active Learning - System Users Report"));
            document.add(new Paragraph("Generated on: " + now.toString()));
            document.add(new Paragraph(" ")); // Blank line for spacing
            
            // Create a table with 3 columns (e.g., ID, Username, Role)
            PdfPTable table = new PdfPTable(3);
            table.addCell("User ID");
            table.addCell("Username");
            table.addCell("Role");

            /* TODO: Uncomment and link to actual UserDAO
            UserDAO userDAO = new UserDAO();
            List<String[]> users = userDAO.getAllUsers(); 
            
            for (String[] user : users) {
                table.addCell(user[0]); // ID
                
                // Add the required asterisk for the active user
                if (user[1].equals(activeUser)) {
                    table.addCell("* " + user[1]);
                } else {
                    table.addCell(user[1]);
                }
                
                table.addCell(user[2]); // Role
            }
            */

            // TEMPORARY MOCK DATA TO TEST THE PDF RIGHT NOW
            table.addCell("1");
            table.addCell("admin_01");
            table.addCell("Admin");
            
            table.addCell("2");
            table.addCell("* " + activeUser); // Mocking the active user detection
            table.addCell("Student");

            // Add table to document and close
            document.add(table);
            document.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error generating the Admin User PDF.");
            request.getRequestDispatcher("/general_error.jsp").forward(request, response);
        }
    }
}