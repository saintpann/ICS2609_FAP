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

@WebServlet(name = "ReportServlet", urlPatterns = {"/generateAdminReport"})
public class ReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
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
            Document document = new Document(PageSize.A4.rotate());
            PdfWriter.getInstance(document, response.getOutputStream());
            
            document.open();
            
            document.add(new Paragraph("Active Learning - System Users Report"));
            document.add(new Paragraph("Generated on: " + now.toString()));
            document.add(new Paragraph(" "));
            
            PdfPTable table = new PdfPTable(3);
            table.addCell("User ID");
            table.addCell("Username");
            table.addCell("Role");

            UserDAO userDAO = new UserDAO();
            List<String[]> users = userDAO.getAllUsers(); 
            
            for (String[] user : users) {
                table.addCell(user[0]); 
                
                if (user[1].equals(activeUser)) {
                    table.addCell("* " + user[1]);
                } else {
                    table.addCell(user[1]);
                }
                
                table.addCell(user[2]); 
            }

            document.add(table);
            document.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error generating the Admin User PDF.");
            request.getRequestDispatcher("/general_error.jsp").forward(request, response);
        }
    }
}