<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="tools.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || "admin".equalsIgnoreCase(currentUser.getRole().trim())) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    List<Map<String, String>> courses = (List<Map<String, String>>) request.getAttribute("courses");
%>
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
    <meta charset="UTF-8">
    <title>Available Exams</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            /* NexaFlow Premium Palette Matrix */
            --bg-gradient: radial-gradient(circle at 50% 0%, #1a103c 0%, #000000 100%);
            --card-bg: rgba(26, 18, 44, 0.6);
            --sidebar-bg: #070512;
            --accent-purple: #8B5CF6;
            --border-glass: rgba(255, 255, 255, 0.05);
            --border-glass-top: rgba(255, 255, 255, 0.12);
            --text-heading: #ffffff;
            --text-body: #cbd5e1;
            --text-muted: #64748b;
        }

        body { font-family: 'Plus Jakarta Sans', sans-serif; background: var(--bg-gradient); background-attachment: fixed; color: var(--text-body); min-height: 100vh; margin: 0; position: relative; }
        body::before { content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%; opacity: 0.03; z-index: 1; pointer-events: none; background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)'/%3E%3C/svg%3E"); }
        
        .sidebar { background-color: var(--sidebar-bg); border-right: 1px solid var(--border-glass); min-height: 100vh; position: fixed; top: 0; left: 0; width: 260px; padding-top: 1.75rem; z-index: 100; transition: transform 0.3s ease; }
        .main-content { margin-left: 260px; padding: 2.5rem; position: relative; z-index: 2; }
        
        .nav-link-custom { display: flex; align-items: center; padding: 0.8rem 1.25rem; color: var(--text-muted); text-decoration: none; border-radius: 12px; margin: 0.25rem 1.25rem; font-weight: 500; font-size: 0.95rem; transition: all 0.2s ease; border: 1px solid transparent; }
        .nav-link-custom:hover, .nav-link-custom.active { background-color: rgba(139, 92, 246, 0.08); color: #a78bfa; }
        .nav-link-custom.active { border: 1px solid rgba(139, 92, 246, 0.2); background-color: rgba(139, 92, 246, 0.12); }
        .nav-link-custom i { font-size: 1.2rem; margin-right: 0.85rem; }

        .bento-card { background: var(--card-bg); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); border: 1px solid var(--border-glass); border-top: 1px solid var(--border-glass-top); border-radius: 20px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4); padding: 2rem; display: flex; flex-direction: column; height: 100%; transition: transform 0.2s ease, box-shadow 0.2s ease; }
        .bento-card:hover { transform: translateY(-3px); box-shadow: 0 15px 35px rgba(0, 0, 0, 0.5), 0 0 25px rgba(139, 92, 246, 0.1); }

        /* Mobile Layout Configuration Definitions */
        .mobile-header-bar {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; height: 70px;
            background-color: var(--sidebar-bg);
            border-bottom: 1px solid var(--border-glass);
            z-index: 1030;
            padding: 0 1.5rem;
            align-items: center;
            justify-content: space-between;
        }

        .btn-hamburger-toggle {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--border-glass);
            color: #ffffff;
            border-radius: 8px;
            padding: 0.4rem 0.75rem;
            font-size: 1.25rem;
        }

        @media (max-width: 991.98px) {
            .mobile-header-bar {
                display: flex;
            }
            .sidebar {
                transform: translateX(-100%);
                width: 280px;
                z-index: 1050;
            }
            .sidebar.drawer-active {
                transform: translateX(0);
            }
            .main-content {
                margin-left: 0;
                padding: 6.5rem 1.25rem 2.5rem 1.25rem;
            }
        }
    </style>
</head>
<body>

    <div class="mobile-header-bar">
        <div class="d-flex align-items-center">
            <i class="bi bi-mortarboard-fill fs-4 me-2" style="color: #0D6EFD;"></i>
            <span class="fw-bold text-white">EduPortal</span>
        </div>
        <button class="btn btn-hamburger-toggle" type="button" onclick="handleSidebarDisplayToggle('toggle')">
            <i class="bi bi-list"></i>
        </button>
    </div>

    <aside class="sidebar" id="globalAppSidebarContainer">
        <div class="px-4 mb-4 d-flex align-items-center justify-content-between">
            <div class="d-flex align-items-center">
                <i class="bi bi-mortarboard-fill fs-3 me-2" style="color: #0D6EFD;"></i>
                <span class="fw-bold fs-5 text-white">EduPortal Student</span>
            </div>
            <button type="button" class="btn-close btn-close-white d-lg-none" onclick="handleSidebarDisplayToggle(false)"></button>
        </div>
        <nav class="nav flex-column">
            <a class="nav-link-custom" href="${pageContext.request.contextPath}/app/student_dashboard.jsp"><i class="bi bi-house-door-fill"></i> Dashboard</a>
            <a class="nav-link-custom active" href="${pageContext.request.contextPath}/takeExam"><i class="bi bi-pencil-square text-primary"></i> Take Exam</a>
            <hr class="mx-3 border-secondary border-opacity-50">
            <a class="nav-link-custom" href="${pageContext.request.contextPath}/settings.jsp"><i class="bi bi-gear-fill"></i> Account Settings</a>
            <a class="nav-link-custom text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-left"></i> Sign Out</a>
        </nav>
    </aside>

    <main class="main-content">
        <header class="mb-5">
            <h3 class="fw-bold text-white m-0">Certification Exams</h3>
            <p class="text-muted m-0">Select a course module to test your knowledge.</p>
        </header>

        <div class="row g-4">
            <% if (courses != null && !courses.isEmpty()) { 
                for (Map<String, String> course : courses) { %>
                <div class="col-md-6 col-lg-4">
                    <div class="bento-card">
                        <div class="d-flex align-items-center mb-3">
                            <span class="badge bg-primary bg-opacity-25 text-primary border border-primary border-opacity-50 px-2 py-1 me-2"><%= course.get("course_code") %></span>
                        </div>
                        <h5 class="fw-bold text-white mb-2"><%= course.get("course_title") %></h5>
                        <p class="text-muted small mb-4 flex-grow-1"><%= course.get("description") != null ? course.get("description") : "Official system certification exam." %></p>
                        
                        <a href="${pageContext.request.contextPath}/takeExam?courseId=<%= course.get("course_id") %>&courseCode=<%= course.get("course_code") %>" class="btn w-100 fw-bold py-2 rounded-3" style="background-color: var(--accent-purple); color: white;">
                            <i class="bi bi-play-fill me-1"></i> Start Exam
                        </a>
                    </div>
                </div>
            <% }} else { %>
                <div class="col-12">
                    <div class="alert alert-secondary bg-opacity-10 border-0 text-white text-center py-5">
                        <i class="bi bi-inbox fs-1 text-muted d-block mb-3"></i>
                        <h5>No Exams Available</h5>
                        <p class="text-muted small">Your administrator has not published any courses yet.</p>
                    </div>
                </div>
            <% } %>
        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // MODIFIED: State validation toggle evaluation rules
        function handleSidebarDisplayToggle(actionState) {
            const sidebar = document.getElementById('globalAppSidebarContainer');
            if (!sidebar) return;
            
            if (actionState === 'toggle') {
                // If it contains the class, remove it (close); otherwise, add it (open)
                if (sidebar.classList.contains('drawer-active')) {
                    sidebar.classList.remove('drawer-active');
                } else {
                    sidebar.classList.add('drawer-active');
                }
            } else if (actionState === true) {
                sidebar.classList.add('drawer-active');
            } else {
                sidebar.classList.remove('drawer-active');
            }
        }
    </script>
</body>
</html>