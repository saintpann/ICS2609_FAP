<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="tools.User" %>
<%
    // Safely cast the user object for displaying the name in the HTML
    User currentUser = (User) session.getAttribute("currentUser");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin System Control Panel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: #f8f9fa;
            min-height: 100vh;
        }
        .sidebar {
            background-color: #ffffff;
            border-right: 1px solid #e2e8f0;
            min-height: 100vh;
            position: fixed;
            top: 0;
            left: 0;
            width: 260px;
            padding-top: 1.5rem;
            z-index: 100;
        }
        .main-content {
            margin-left: 260px;
            padding: 2rem;
        }
        .nav-link-custom {
            display: flex;
            align-items: center;
            padding: 0.75rem 1.25rem;
            color: #64748b;
            text-decoration: none;
            border-radius: 8px;
            margin: 0.25rem 1rem;
            font-weight: 500;
            transition: all 0.2s ease;
        }
        .nav-link-custom:hover, .nav-link-custom.active {
            background-color: #f1f5f9;
            color: #8B5CF6;
        }
        .nav-link-custom i {
            font-size: 1.25rem;
            margin-right: 0.75rem;
        }
        .bento-card {
            background: #ffffff;
            border: none;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.02);
            padding: 2rem;
            height: 100%;
        }
    </style>
</head>
<body>

    <aside class="sidebar">
        <div class="px-4 mb-4 d-flex align-items-center">
            <i class="bi bi-shield-lock-fill fs-3 me-2" style="color: #8B5CF6;"></i>
            <span class="fw-bold fs-5 text-dark">EduPortal Admin</span>
        </div>
        <nav class="nav flex-column">
            <a class="nav-link-custom active" href="#"><i class="bi bi-sliders"></i> Control Center</a>
            <a class="nav-link-custom" href="${pageContext.request.contextPath}/app/reports.jsp"><i class="bi bi-file-earmark-bar-graph-fill"></i> System Reports</a>
            <hr class="mx-3 text-muted">
            <a class="nav-link-custom text-danger" href="logout"><i class="bi bi-box-arrow-left"></i> Sign Out</a>
        </nav>
    </aside>

    <main class="main-content">
        <header class="mb-4">
            <h4 class="fw-bold m-0">System Administration Panel</h4>
            <p class="text-muted small m-0">Monitor accounts and run date-bound performance audits.</p>
        </header>

        <section class="row g-4 mb-4">
            <div class="col-12 col-md-6">
                <div class="card bento-card">
                    <h5 class="fw-bold text-dark">User System Accounts</h5>
                    <p class="text-muted small">View, provision, audit, or restrict active student and faculty nodes across the directory repository.</p>
                    <a href="${pageContext.request.contextPath}/directory" class="btn btn-light btn-sm fw-semibold mt-3 w-50" style="color: #8B5CF6;">View Directory →</a>
                </div>
            </div>
            <div class="col-12 col-md-6">
                <div class="card bento-card">
                    <h5 class="fw-bold text-dark">Report Engine Center</h5>
                    <p class="text-muted small">Configure date range metrics to evaluate score sheets and log system audits instantly.</p>
                    <a href="${pageContext.request.contextPath}/app/reports.jsp" class="btn btn-light btn-sm fw-semibold mt-3 w-50" style="color: #2DD4BF;">Open Reports Form →</a>
                </div>
            </div>
        </section>
    </main>

</body>
</html>