<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="tools.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    boolean isAdmin = "admin".equalsIgnoreCase(currentUser.getRole().trim());
%>
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
    <meta charset="UTF-8">
    <title>Account Settings</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            /* NexaFlow Premium Admin Palette */
            --bg-gradient: radial-gradient(circle at 50% 0%, #1a103c 0%, #000000 100%);
            --card-bg: rgba(26, 18, 44, 0.6);
            --sidebar-bg: #070512;
            --accent-purple: #8B5CF6;
            --accent-teal: #2DD4BF;
            --border-glass: rgba(255, 255, 255, 0.05);
            --border-glass-top: rgba(255, 255, 255, 0.12);
            --text-heading: #ffffff;
            --text-body: #cbd5e1;
            --text-muted: #64748b;
        }

        body { font-family: 'Plus Jakarta Sans', sans-serif; background: var(--bg-gradient); background-attachment: fixed; color: var(--text-body); min-height: 100vh; margin: 0; position: relative; }
        
        body::before {
            content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%; opacity: 0.03; z-index: 1; pointer-events: none;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)'/%3E%3C/svg%3E");
        }

        .sidebar { background-color: var(--sidebar-bg); border-right: 1px solid var(--border-glass); min-height: 100vh; position: fixed; top: 0; left: 0; width: 260px; padding-top: 1.75rem; z-index: 100; }
        .main-content { margin-left: 260px; padding: 2.5rem; position: relative; z-index: 2; }
        
        .nav-link-custom { display: flex; align-items: center; padding: 0.8rem 1.25rem; color: var(--text-muted); text-decoration: none; border-radius: 12px; margin: 0.25rem 1.25rem; font-weight: 500; font-size: 0.95rem; transition: all 0.2s ease; border: 1px solid transparent; }
        .nav-link-custom:hover, .nav-link-custom.active { background-color: rgba(139, 92, 246, 0.08); color: #a78bfa; }
        .nav-link-custom.active { border: 1px solid rgba(139, 92, 246, 0.2); background-color: rgba(139, 92, 246, 0.12); }
        .nav-link-custom i { font-size: 1.2rem; margin-right: 0.85rem; }

        h4, h5, h6 { color: var(--text-heading); }

        .bento-card { background: var(--card-bg); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); border: 1px solid var(--border-glass); border-top: 1px solid var(--border-glass-top); border-radius: 20px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4); padding: 2.25rem; display: flex; flex-direction: column; transition: transform 0.2s ease, box-shadow 0.2s ease; margin-bottom: 2rem;}
        .bento-card:hover { transform: translateY(-2px); box-shadow: 0 15px 35px rgba(0, 0, 0, 0.5), 0 0 25px rgba(139, 92, 246, 0.05); }

        .danger-card { background: rgba(239, 68, 68, 0.05); border: 1px solid rgba(239, 68, 68, 0.2); }
        .danger-card:hover { box-shadow: 0 15px 35px rgba(0, 0, 0, 0.5), 0 0 25px rgba(239, 68, 68, 0.1); }

        /* Transparent Inputs */
        .form-control { background-color: rgba(255, 255, 255, 0.03); border: 1px solid var(--border-glass); color: white; }
        .form-control:focus { background-color: rgba(255, 255, 255, 0.06); border-color: var(--accent-purple); box-shadow: 0 0 0 0.25rem rgba(139, 92, 246, 0.25); color: white;}
    </style>
</head>
<body>

    <aside class="sidebar">
        <div class="px-4 mb-4 d-flex align-items-center">
            <% if (isAdmin) { %>
                <i class="bi bi-shield-lock-fill fs-3 me-2" style="color: #8B5CF6;"></i>
                <span class="fw-bold fs-5 text-white">EduPortal Admin</span>
            <% } else { %>
                <i class="bi bi-mortarboard-fill fs-3 me-2" style="color: #0D6EFD;"></i>
                <span class="fw-bold fs-5 text-white">EduPortal Student</span>
            <% } %>
        </div>
        
        <nav class="nav flex-column">
            <% if (isAdmin) { %>
                <a class="nav-link-custom" href="${pageContext.request.contextPath}/app/admin_dashboard.jsp"><i class="bi bi-sliders"></i> Control Center</a>
                <a class="nav-link-custom" href="${pageContext.request.contextPath}/app/reports.jsp"><i class="bi bi-file-earmark-bar-graph-fill"></i> System Reports</a>
                <a class="nav-link-custom" href="${pageContext.request.contextPath}/directory"><i class="bi bi-people-fill"></i> User Directory</a>
            <% } else { %>
                <a class="nav-link-custom" href="${pageContext.request.contextPath}/app/student_dashboard.jsp"><i class="bi bi-house-door-fill"></i> Dashboard</a>
                <a class="nav-link-custom" href="${pageContext.request.contextPath}/takeExam"><i class="bi bi-pencil-square"></i> Take Exam</a>
            <% } %>
            
            <hr class="mx-3 border-secondary border-opacity-50">
            <a class="nav-link-custom active" href="${pageContext.request.contextPath}/settings.jsp"><i class="bi bi-gear-fill"></i> Account Settings</a>
            <a class="nav-link-custom text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-left"></i> Sign Out</a>
        </nav>
    </aside>

    <main class="main-content">
        <header class="mb-4">
            <h4 class="fw-bold m-0">Account Settings</h4>
            <p class="text-muted small m-0">Manage your security preferences and data.</p>
        </header>

        <div style="max-width: 800px;">
            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-danger small py-2 fw-semibold border-0 bg-danger bg-opacity-25 text-white"><%= request.getParameter("error") %></div>
            <% } %>
            <% if (request.getParameter("success") != null) { %>
                <div class="alert alert-success small py-2 fw-semibold border-0 bg-success bg-opacity-25 text-white"><%= request.getParameter("success") %></div>
            <% } %>

            <div class="bento-card">
                <h5 class="fw-bold mb-1"><i class="bi bi-key-fill text-primary me-2"></i>Change Password</h5>
                <p class="text-muted small mb-4">Ensure your account is using a long, random password to stay secure.</p>
                
                <form action="${pageContext.request.contextPath}/userSettings" method="POST">
                    <input type="hidden" name="action" value="changePassword">
                    <div class="mb-3">
                        <label class="form-label small fw-semibold text-light">New Password</label>
                        <input type="password" name="newPass" class="form-control p-2.5 rounded-3" required>
                    </div>
                    <div class="mb-4">
                        <label class="form-label small fw-semibold text-light">Confirm New Password</label>
                        <input type="password" name="confirmPass" class="form-control p-2.5 rounded-3" required>
                    </div>
                    <button type="submit" class="btn fw-bold px-4 py-2.5 rounded-3 w-100" style="background-color: var(--accent-purple); color: white;">Update Password</button>
                </form>
            </div>

            <div class="bento-card danger-card">
                <h5 class="fw-bold text-danger mb-1"><i class="bi bi-exclamation-triangle-fill me-2"></i>Danger Zone</h5>
                <p class="text-muted small mb-4">Permanently delete your account and wipe all certification records from the system.</p>
                
                <form action="${pageContext.request.contextPath}/userSettings" method="POST" onsubmit="return confirm('Are you absolutely sure you want to delete your account? This cannot be undone.');">
                    <input type="hidden" name="action" value="deleteAccount">
                    <button type="submit" class="btn btn-danger fw-bold px-4 py-2.5 rounded-3 w-100">Delete Account</button>
                </form>
            </div>
        </div>
    </main>

</body>
</html>