package controller;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.ColumnText;
import com.itextpdf.text.pdf.PdfContentByte;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPageEventHelper;
import com.itextpdf.text.pdf.PdfWriter;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import tools.CertDAO;
import tools.Cryptograph;
import tools.User;
import tools.UserDAO;

@WebServlet(name = "ReportServlet", urlPatterns = {"/generateReport"})
public class ReportServlet extends HttpServlet {

    // --- INNER CLASS: Timestamp Watermark Generator ---
    static class WatermarkPageEvent extends PdfPageEventHelper {
        private final String watermarkText;

        public WatermarkPageEvent(String watermarkText) {
            this.watermarkText = watermarkText;
        }

        @Override
        public void onEndPage(PdfWriter writer, Document document) {
            PdfContentByte canvas = writer.getDirectContentUnder();
            // Light grey, semi-transparent text
            Font font = new Font(Font.FontFamily.HELVETICA, 40, Font.BOLD, new BaseColor(200, 200, 200, 80));
            Phrase watermark = new Phrase(watermarkText, font);
            // Draw diagonally across the center of the page
            ColumnText.showTextAligned(canvas, Element.ALIGN_CENTER, watermark,
                    document.getPageSize().getWidth() / 2, document.getPageSize().getHeight() / 2, 35);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Validate General Session (Allow both Students and Admins in)
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) { action = "dateRange"; } 

        try {
            // ADMIN ONLY ACTIONS
            if ("allUsers".equals(action) || "dateRange".equals(action)) {
                if (!"admin".equalsIgnoreCase(currentUser.getRole().trim())) {
                    response.sendRedirect(request.getContextPath() + "/index.jsp");
                    return;
                }
                
                if ("allUsers".equals(action)) {
                    generateAllUsersReport(request, response, currentUser);
                } else {
                    generateDateRangeReport(request, response, currentUser);
                }
            } 
            // ANY USER ACTIONS
            else if ("selfReport".equals(action)) {
                generateSelfReport(request, response, currentUser);
            } 
            // NEW: CERTIFICATE ROUTING
            else if ("printCertificates".equals(action)) {
                generateCertificatesReport(request, response, currentUser); 
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error generating the requested PDF.");
            request.getRequestDispatcher("/WEB-INF/jsps/errorpages/error_404.jsp").forward(request, response);
        }
    }
    private void generateCertificatesReport(HttpServletRequest request, HttpServletResponse response, User user) throws Exception {
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"Certificates_" + user.getUsername() + ".pdf\"");

        // Force Landscape mode for certificate layout
        Document document = new Document(PageSize.A4.rotate());
        PdfWriter writer = PdfWriter.getInstance(document, response.getOutputStream());
        document.open();

        CertDAO certDAO = new CertDAO();
        List<Map<String, String>> certs;

        // Determine data scope based on role
        if ("admin".equalsIgnoreCase(user.getRole().trim())) {
            // Admins batch-print everything (Using a massive date range to grab all records)
            certs = certDAO.getCertificationsByDate(getServletContext(), "2000-01-01", "2099-12-31");
        } else {
            // Students only print their own
            certs = certDAO.getStudentCertifications(getServletContext(), user.getUsername());
        }

        if (certs == null || certs.isEmpty()) {
            document.add(new Paragraph("No certifications found to print."));
            document.close();
            return;
        }

        // Setup custom fonts for the certificate design
        Font titleFont = new Font(Font.FontFamily.TIMES_ROMAN, 34, Font.BOLD, new BaseColor(139, 92, 246));
        Font subFont = new Font(Font.FontFamily.HELVETICA, 16, Font.NORMAL, BaseColor.DARK_GRAY);
        Font nameFont = new Font(Font.FontFamily.HELVETICA, 28, Font.BOLD, BaseColor.BLACK);
        Font courseFont = new Font(Font.FontFamily.HELVETICA, 24, Font.BOLD, new BaseColor(45, 212, 191));
        Font detailFont = new Font(Font.FontFamily.HELVETICA, 12, Font.ITALIC, BaseColor.GRAY);

        // Generate one page per certificate
        for (int i = 0; i < certs.size(); i++) {
            if (i > 0) { document.newPage(); }
            
            Map<String, String> cert = certs.get(i);

            // Draw Certificate Outer Border (Purple)
            PdfContentByte canvas = writer.getDirectContent();
            canvas.rectangle(30, 30, document.getPageSize().getWidth() - 60, document.getPageSize().getHeight() - 60);
            canvas.setLineWidth(8);
            canvas.setRGBColorStroke(139, 92, 246);
            canvas.stroke();
            
            // Draw Certificate Inner Border (Teal)
            canvas.rectangle(40, 40, document.getPageSize().getWidth() - 80, document.getPageSize().getHeight() - 80);
            canvas.setLineWidth(2);
            canvas.setRGBColorStroke(45, 212, 191);
            canvas.stroke();

            // Assemble Text Content
            Paragraph p = new Paragraph("\n\n\nCERTIFICATE OF COMPLETION\n", titleFont);
            p.setAlignment(Element.ALIGN_CENTER);
            document.add(p);

            p = new Paragraph("\nThis is to certify that\n", subFont);
            p.setAlignment(Element.ALIGN_CENTER);
            document.add(p);

            // Dynamically grab the student name (Crucial for Admin batch printing)
            String certOwner = cert.containsKey("uname") ? cert.get("uname") : user.getUsername();
            p = new Paragraph("\n" + certOwner.toUpperCase() + "\n", nameFont);
            p.setAlignment(Element.ALIGN_CENTER);
            document.add(p);

            p = new Paragraph("\nhas successfully completed the system course requirement:\n", subFont);
            p.setAlignment(Element.ALIGN_CENTER);
            document.add(p);

            p = new Paragraph("\n" + cert.get("course_code") + "\n", courseFont);
            p.setAlignment(Element.ALIGN_CENTER);
            document.add(p);

            p = new Paragraph("\nAchieving a verified score of " + cert.get("score") + "%\n", detailFont);
            p.setAlignment(Element.ALIGN_CENTER);
            document.add(p);

            p = new Paragraph("Official Issue Date: " + cert.get("issue_date"), detailFont);
            p.setAlignment(Element.ALIGN_CENTER);
            document.add(p);
        }

        document.close();
    }

    // ========================================================================
    // REPORT 1: Master User Directory (All Users + Decoded Passwords)
    // ========================================================================
    private void generateAllUsersReport(HttpServletRequest request, HttpServletResponse response, User admin) throws Exception {
        LocalDateTime now = LocalDateTime.now();
        String timestamp = now.format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String readableTime = now.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"Master_Directory_" + timestamp + ".pdf\"");

        // Setup Document in LANDSCAPE mode
        Document document = new Document(PageSize.A4.rotate());
        PdfWriter writer = PdfWriter.getInstance(document, response.getOutputStream());
        
        // Attach the Watermark
        writer.setPageEvent(new WatermarkPageEvent("EduPortal Audit - " + readableTime));
        document.open();
        
        Font titleFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
        Font headerFont = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD, BaseColor.WHITE);
        Font normalFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL);

        document.add(new Paragraph("EduPortal - Master User Directory", titleFont));
        document.add(new Paragraph("Generated by Admin: " + admin.getUsername()));
        document.add(new Paragraph("Audit Timestamp: " + readableTime));
        document.add(new Paragraph(" ")); 

        // Create 5-Column Table
        PdfPTable table = new PdfPTable(5);
        table.setWidthPercentage(100);
        table.setWidths(new float[]{2f, 2f, 1.5f, 1.5f, 4f}); // Proportional column widths
        
        String[] headers = {"Username", "Encoded Password", "Role", "Total Certs", "Course IDs Completed"};
        for (String header : headers) {
            PdfPCell cell = new PdfPCell(new Phrase(header, headerFont));
            cell.setBackgroundColor(new BaseColor(45, 212, 191)); // Teal Theme
            cell.setPadding(8);
            table.addCell(cell);
        }

        // Initialize Crypto tools (Update these keys to match your DataSeeder!)
        String secretKey = getServletContext().getInitParameter("SecretKey");
        if (secretKey == null) secretKey = "MySecretKey"; // Fallback
        Cryptograph crypt = new Cryptograph(secretKey, "AES", "ECB", "PKCS5Padding");

        // Fetch Data
        UserDAO userDAO = new UserDAO();
        CertDAO certDAO = new CertDAO();
        List<User> users = userDAO.getAllUsers(getServletContext());

        for (User u : users) {
            table.addCell(new Phrase(u.getUsername(), normalFont));
            
            // Decrypt Password
            String encodedPass = u.getPassword();
            if (encodedPass == null || encodedPass.trim().isEmpty()) {
                encodedPass = "[No Password Data]";
            }
            
            // iText will automatically wrap the long encrypted string in the table cell
            table.addCell(new Phrase(encodedPass, normalFont));
            
            table.addCell(new Phrase(u.getRole(), normalFont));
            
            // Fetch Certifications for this specific user
            List<Map<String, String>> certs = certDAO.getStudentCertifications(getServletContext(), u.getUsername());
            table.addCell(new Phrase(String.valueOf(certs.size()), normalFont));
            
            // Format Course IDs
            StringBuilder courseList = new StringBuilder();
            for (int i = 0; i < certs.size(); i++) {
                courseList.append(certs.get(i).get("course_code"));
                if (i < certs.size() - 1) courseList.append(", ");
            }
            String finalCourses = courseList.length() > 0 ? courseList.toString() : "None";
            table.addCell(new Phrase(finalCourses, normalFont));
        }

        document.add(table);
        document.close();
    }

    // ========================================================================
    // REPORT 2: The Original Date Range Report
    // ========================================================================
    private void generateDateRangeReport(HttpServletRequest request, HttpServletResponse response, User admin) throws Exception {
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        LocalDateTime now = LocalDateTime.now();
        String timestamp = now.format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"Performance_Audit_" + timestamp + ".pdf\"");

        Document document = new Document(PageSize.A4);
        PdfWriter.getInstance(document, response.getOutputStream());
        document.open();
        
        Font titleFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
        Font headerFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, BaseColor.WHITE);
        Font normalFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL);
        
        document.add(new Paragraph("EduPortal System - Performance Audit", titleFont));
        document.add(new Paragraph("Report Timeframe: " + startDate + " to " + endDate));
        document.add(new Paragraph("Generated by Admin: " + admin.getUsername()));
        document.add(new Paragraph(" ")); 
        
        PdfPTable table = new PdfPTable(4);
        table.setWidthPercentage(100);
        
        String[] headers = {"Student Username", "Course Code", "Score (%)", "Timestamp"};
        for (String header : headers) {
            PdfPCell cell = new PdfPCell(new Phrase(header, headerFont));
            cell.setBackgroundColor(new BaseColor(139, 92, 246));
            cell.setPadding(8);
            table.addCell(cell);
        }

        CertDAO certDAO = new CertDAO();
        List<Map<String, String>> auditLogs = certDAO.getCertificationsByDate(getServletContext(), startDate, endDate); 
        
        if (auditLogs.isEmpty()) {
            PdfPCell emptyCell = new PdfPCell(new Phrase("No exams completed in this timeframe.", normalFont));
            emptyCell.setColspan(4);
            emptyCell.setHorizontalAlignment(Element.ALIGN_CENTER);
            emptyCell.setPadding(10);
            table.addCell(emptyCell);
        } else {
            for (Map<String, String> log : auditLogs) {
                table.addCell(new Phrase(log.get("uname"), normalFont));
                table.addCell(new Phrase(log.get("course_code"), normalFont));
                table.addCell(new Phrase(log.get("score") + "%", normalFont));
                table.addCell(new Phrase(log.get("issue_date"), normalFont));
            }
        }
        document.add(table);
        document.close();
    }
    private void generateSelfReport(HttpServletRequest request, HttpServletResponse response, User user) throws Exception {
        LocalDateTime now = LocalDateTime.now();
        String timestamp = now.format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String readableTime = now.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + user.getUsername() + "_SelfRecord_" + timestamp + ".pdf\"");

        // Setup Document in LANDSCAPE mode
        Document document = new Document(PageSize.A4.rotate());
        PdfWriter writer = PdfWriter.getInstance(document, response.getOutputStream());
        
        // Attach the Watermark
        writer.setPageEvent(new WatermarkPageEvent("Self Record - " + readableTime));
        document.open();
        
        Font titleFont = new Font(Font.FontFamily.HELVETICA, 22, Font.BOLD);
        Font subFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
        Font headerFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, BaseColor.WHITE);
        Font normalFont = new Font(Font.FontFamily.HELVETICA, 11, Font.NORMAL);

        // 1. Initialize Cryptograph
        // 1. Initialize Cryptograph
        String secretKey = getServletContext().getInitParameter("secretKey"); // Lowercase 's'!
        String algo = getServletContext().getInitParameter("cipherAlgorithm");
        String mode = getServletContext().getInitParameter("cipherMode");
        String padding = getServletContext().getInitParameter("cipherPadding");
        
        Cryptograph crypt = new Cryptograph(secretKey, algo, mode, padding);
        
        // 2. Fetch fresh user data from DB to bypass stale sessions
        UserDAO userDAO = new UserDAO();
        List<User> allUsers = userDAO.getAllUsers(getServletContext());
        String freshEncryptedPass = null;
        
        for (User u : allUsers) {
            if (u.getUsername().equalsIgnoreCase(user.getUsername())) {
                freshEncryptedPass = u.getPassword();
                break;
            }
        }

        // 3. Decrypt the fresh password
        String decodedPass = "[No Password Found]";
        if (freshEncryptedPass != null) {
            try {
                decodedPass = crypt.decrypt(freshEncryptedPass);
            } catch (Exception e) {
                decodedPass = "[Decryption Error - Raw: " + freshEncryptedPass + "]";
            }
        }

        // 4. Add text to the PDF
        document.add(new Paragraph("EduPortal - Personal Account Record", titleFont));
        document.add(new Paragraph(" "));
        document.add(new Paragraph("Username: " + user.getUsername(), subFont));
        
        // Print the Decoded Password
        document.add(new Paragraph("Decoded Password: " + decodedPass, subFont)); 
        
        document.add(new Paragraph("System Role: " + (user.getRole().substring(0,1).toUpperCase() + user.getRole().substring(1).toLowerCase()), subFont));
        document.add(new Paragraph("Audit Timestamp: " + readableTime, subFont));
        document.add(new Paragraph(" "));

        // Fetch User's Certifications
        CertDAO certDAO = new CertDAO();
        List<Map<String, String>> certs = certDAO.getStudentCertifications(getServletContext(), user.getUsername());

        // Create 3-Column Table for Exam History
        PdfPTable table = new PdfPTable(3);
        table.setWidthPercentage(100);
        
        String[] headers = {"Course Code", "Achieved Score", "Date of Issue"};
        for (String header : headers) {
            PdfPCell cell = new PdfPCell(new Phrase(header, headerFont));
            // Use different header colors based on role
            if ("admin".equalsIgnoreCase(user.getRole().trim())) {
                cell.setBackgroundColor(new BaseColor(220, 53, 69)); // Admin Red
            } else {
                cell.setBackgroundColor(new BaseColor(13, 110, 253)); // Student Blue
            }
            cell.setPadding(8);
            table.addCell(cell);
        }

        if (certs == null || certs.isEmpty()) {
            PdfPCell emptyCell = new PdfPCell(new Phrase("No exam history found for this account.", normalFont));
            emptyCell.setColspan(3);
            emptyCell.setHorizontalAlignment(Element.ALIGN_CENTER);
            emptyCell.setPadding(10);
            table.addCell(emptyCell);
        } else {
            for (Map<String, String> cert : certs) {
                table.addCell(new Phrase(cert.get("course_code"), normalFont));
                table.addCell(new Phrase(cert.get("score") + "%", normalFont));
                table.addCell(new Phrase(cert.get("issue_date"), normalFont));
            }
        }

        document.add(table);
        document.close();
    }
}