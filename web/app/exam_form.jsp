<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    List<Map<String, String>> questions = (List<Map<String, String>>) request.getAttribute("questions");
    Integer courseId = (Integer) request.getAttribute("courseId");
    String courseCode = (String) request.getAttribute("courseCode");
%>
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
    <meta charset="UTF-8">
    <title>Active Examination</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root { --bg-gradient: radial-gradient(circle at 50% 0%, #1a103c 0%, #000000 100%); --card-bg: rgba(26, 18, 44, 0.6); --border-glass: rgba(255, 255, 255, 0.05); --border-glass-top: rgba(255, 255, 255, 0.12); --accent-purple: #8B5CF6; }
        body { font-family: 'Plus Jakarta Sans', sans-serif; background: var(--bg-gradient); background-attachment: fixed; color: #cbd5e1; min-height: 100vh; }
        .exam-container { max-width: 800px; margin: 3rem auto; padding: 0 1rem; }
        .bento-card { background: var(--card-bg); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); border: 1px solid var(--border-glass); border-top: 1px solid var(--border-glass-top); border-radius: 20px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4); padding: 2rem; margin-bottom: 1.5rem; }
        .form-control { background-color: rgba(255, 255, 255, 0.03); border: 1px solid var(--border-glass); color: white; padding: 0.8rem 1rem; }
        .form-control:focus { background-color: rgba(255, 255, 255, 0.06); border-color: var(--accent-purple); box-shadow: 0 0 0 0.25rem rgba(139, 92, 246, 0.25); color: white;}
    </style>
</head>
<body>
    <div class="exam-container">
        <div class="d-flex align-items-center mb-4">
            <a href="${pageContext.request.contextPath}/takeExam" class="btn btn-dark border border-secondary rounded-circle me-3"><i class="bi bi-arrow-left"></i></a>
            <div>
                <h3 class="fw-bold text-white m-0">Course Module: <%= courseCode %></h3>
                <p class="text-muted small m-0">Provide short answers for the following questions.</p>
            </div>
        </div>

        <form action="${pageContext.request.contextPath}/gradeExam" method="POST">
            <input type="hidden" name="courseId" value="<%= courseId %>">
            <input type="hidden" name="courseCode" value="<%= courseCode %>">

            <% if (questions == null || questions.isEmpty()) { %>
                <div class="alert alert-danger bg-danger bg-opacity-10 border border-danger p-4 text-center rounded-4">
                    <i class="bi bi-exclamation-triangle-fill fs-2 text-danger d-block mb-2"></i>
                    <h5 class="fw-bold text-white">No Questions Found!</h5>
                    <p class="mb-0 text-light small">The Java backend connected successfully, but PostgreSQL returned 0 rows for courseId: <strong><%= courseId %></strong>.<br>Verify that your SQL inserts were committed to the database.</p>
                </div>
            <% } else { 
                int qNum = 1;
                for (Map<String, String> q : questions) { %>
                
                <div class="bento-card">
                    <h5 class="fw-bold text-white mb-3">
                        <span class="text-primary me-2"><%= qNum %>.</span> <%= q.get("question_text") %>
                    </h5>
                    <div class="mt-2">
                        <input type="text" name="q_<%= q.get("question_id") %>" class="form-control rounded-3" placeholder="Type your answer here..." autocomplete="off" required>
                    </div>
                </div>
            <% qNum++; }} %>

            <div class="text-end mt-4 mb-5">
                <button type="submit" class="btn fw-bold px-5 py-3 rounded-3 fs-5 shadow-lg" style="background-color: var(--accent-purple); color: white;" <%= (questions == null || questions.isEmpty()) ? "disabled" : "" %>>
                    <i class="bi bi-check2-circle me-2"></i> Submit Examination
                </button>
            </div>
        </form>
    </div>
</body>
</html>