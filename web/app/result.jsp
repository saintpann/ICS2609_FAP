<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    String courseCode = (String) request.getAttribute("courseCode");
    String finalScore = (String) request.getAttribute("finalScore");
    Boolean passed = (Boolean) request.getAttribute("passed");
%>
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
    <meta charset="UTF-8">
    <title>Exam Results</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { 
            font-family: 'Plus Jakarta Sans', sans-serif; 
            background: radial-gradient(circle at 50% 0%, #1a103c 0%, #000000 100%); 
            background-attachment: fixed; 
            color: #cbd5e1; 
            min-height: 100vh; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            margin: 0;
        }
        
        .result-card { 
            background: rgba(26, 18, 44, 0.6); 
            backdrop-filter: blur(12px); 
            border: 1px solid rgba(255,255,255,0.05); 
            border-radius: 24px; 
            padding: 3rem; 
            text-align: center; 
            max-width: 500px; 
            width: 100%; 
            box-shadow: 0 20px 50px rgba(0,0,0,0.5); 
        }
        
        /* FIXED: Replaced static circular width sizing with an expansive capsule constraint to guarantee padding isolation */
        .score-circle { 
            min-width: 130px;
            display: inline-flex; 
            align-items: center; 
            justify-content: center; 
            margin: 0 auto 2rem; 
            font-size: 2.25rem; 
            font-weight: 700; 
            border: 3px solid; 
            border-radius: 100px;
            padding: 0.75rem 2rem;
            white-space: nowrap;
        }
        
        .pass-theme { color: #2DD4BF; border-color: #2DD4BF; background: rgba(45, 212, 191, 0.1); }
        .fail-theme { color: #EF4444; border-color: #EF4444; background: rgba(239, 68, 68, 0.1); }
    </style>
</head>
<body>

    <div class="result-card">
        <% if (passed != null && passed) { %>
            <div class="score-circle pass-theme shadow-lg">
                <%= finalScore %>%
            </div>
            <h2 class="fw-bold text-white mb-2">Certification Earned!</h2>
            <p class="text-muted mb-4">Congratulations! You successfully passed the <strong class="text-white"><%= courseCode %></strong> module requirement and your official certificate has been saved to your profile.</p>
            
            <a href="${pageContext.request.contextPath}/generateReport?action=printCertificates" class="btn w-100 fw-bold py-3 rounded-3 mb-3" style="background-color: #8B5CF6; color: white;">
                <i class="bi bi-printer-fill me-2"></i> Print My Certificates
            </a>
        <% } else { %>
            <div class="score-circle fail-theme shadow-lg">
                <%= finalScore %>%
            </div>
            <h2 class="fw-bold text-white mb-2">Requirement Not Met</h2>
            <p class="text-muted mb-4">You did not reach the required passing threshold for <strong class="text-white"><%= courseCode %></strong>. Please review the course materials and try again.</p>
            
            <a href="${pageContext.request.contextPath}/takeExam" class="btn btn-outline-danger w-100 fw-bold py-3 rounded-3 mb-3">
                <i class="bi bi-arrow-counterclockwise me-2"></i> Retry Examination
            </a>
        <% } %>

        <a href="${pageContext.request.contextPath}/app/student_dashboard.jsp" class="btn btn-dark border border-secondary text-white w-100 fw-bold py-3 rounded-3">
            Return to Dashboard
        </a>
    </div>

</body>
</html>