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
    <title>System Performance Reports</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Plus+Jakarta+Sans:wght@600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            /* NexaFlow Premium Admin Palette Matrix */
            --bg-gradient: radial-gradient(circle at 50% 0%, #1a103c 0%, #000000 100%);
            --card-bg: rgba(26, 18, 44, 0.65);
            --sidebar-bg: #070512;
            /* Accents & Borders */
            --accent-purple: #8B5CF6;
            --accent-purple-glow: rgba(139, 92, 246, 0.12);
            --border-glass: rgba(255, 255, 255, 0.05);
            --border-glass-top: rgba(255, 255, 255, 0.14);
            /* High Contrast Text Rules */
            --text-heading: #ffffff;
            --text-body: #e2e8f0;
            --text-muted: #64748b;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-gradient);
            background-attachment: fixed;
            color: var(--text-body);
            min-height: 100vh;
            margin: 0;
            position: relative;
        }

        /* Subtle SVG Noise Overlay Effect */
        body::before {
            content: "";
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            opacity: 0.03;
            z-index: 1;
            pointer-events: none;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)'/%3E%3C/svg%3E");
        }

        /* Sidebar Layout Construction */
        .sidebar {
            background-color: var(--sidebar-bg);
            border-right: 1px solid var(--border-glass);
            min-height: 100vh;
            position: fixed;
            top: 0;
            left: 0;
            width: 260px;
            padding-top: 1.75rem;
            z-index: 100;
        }

        .main-content {
            margin-left: 260px;
            padding: 2.5rem;
            position: relative;
            z-index: 2;
        }

        .nav-link-custom {
            display: flex;
            align-items: center;
            padding: 0.8rem 1.25rem;
            color: var(--text-muted);
            text-decoration: none;
            border-radius: 12px;
            margin: 0.25rem 1.25rem;
            font-weight: 500;
            font-size: 0.95rem;
            transition: all 0.2s ease;
            border: 1px solid transparent;
        }

        .nav-link-custom:hover, .nav-link-custom.active {
            background-color: rgba(139, 92, 246, 0.08);
            color: #a78bfa;
        }

        .nav-link-custom.active {
            border: 1px solid rgba(139, 92, 246, 0.2);
            background-color: rgba(139, 92, 246, 0.12);
        }

        .nav-link-custom i {
            font-size: 1.2rem;
            margin-right: 0.85rem;
        }

        h4, h5, h6 {
            font-family: 'Plus Jakarta Sans', sans-serif;
            letter-spacing: -0.01em;
            color: var(--text-heading);
        }

        /* Glassmorphic Report Input Panel Form Frame */
        .report-card {
            background: var(--card-bg);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid var(--border-glass);
            border-top: 1px solid var(--border-glass-top);
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4), 0 0 30px var(--accent-purple-glow);
            padding: 2.5rem;
            max-width: 620px;
        }

        /* High Contrast Dark Customization for Date Inputs */
        .form-label {
            color: var(--text-body);
            font-size: 0.85rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .form-control {
            background-color: rgba(10, 6, 20, 0.5) !important;
            border: 1px solid var(--border-glass) !important;
            color: var(--text-heading) !important;
            border-radius: 12px !important;
            transition: all 0.2s ease;
        }

        /* Fix calendar icon visibility color schemes in modern browsers */
        .form-control::-webkit-calendar-picker-indicator {
            filter: invert(1) sepia(1) saturate(5) hue-rotate(220deg);
            cursor: pointer;
            opacity: 0.8;
        }

        .form-control::-webkit-calendar-picker-indicator:hover {
            opacity: 1;
        }

        .form-control:focus {
            border-color: var(--accent-purple) !important;
            box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.25) !important;
        }

        /* Premium Action Compilation Button */
        .btn-compile-logs {
            background-color: var(--accent-purple);
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: #ffffff;
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.2s ease;
            box-shadow: 0 4px 12px rgba(139, 92, 246, 0.25);
        }

        .btn-compile-logs:hover {
            background-color: #7c3aed;
            box-shadow: 0 6px 20px rgba(139, 92, 246, 0.4);
            transform: translateY(-1px);
        }

        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                min-height: auto;
                position: relative;
                border-right: none;
                border-bottom: 1px solid var(--border-glass);
                padding-bottom: 1rem;
            }
            .main-content {
                margin-left: 0;
                padding: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <aside class="sidebar">
        <div class="px-4 mb-4 d-flex align-items-center">
            <i class="bi bi-shield-lock-fill fs-4 me-2" style="color: var(--accent-purple);"></i>
            <span class="fw-bold fs-5 text-white">EduPortal Admin</span>
        </div>
        <nav class="nav flex-column">
            <a class="nav-link-custom" href="${pageContext.request.contextPath}/app/admin_dashboard.jsp"><i class="bi bi-sliders"></i> Control Center</a>
            
            <a class="nav-link-custom text-dark fw-bold bg-light" href="${pageContext.request.contextPath}/app/reports.jsp"><i class="bi bi-file-earmark-bar-graph-fill text-primary"></i> System Reports</a>
            
            <a class="nav-link-custom" href="${pageContext.request.contextPath}/directory"><i class="bi bi-people-fill"></i> User Directory</a>
            
            <hr class="mx-3 text-muted">
            
            <a class="nav-link-custom" href="${pageContext.request.contextPath}/settings.jsp"><i class="bi bi-gear-fill"></i> Account Settings</a>
            
            <a class="nav-link-custom text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-left"></i> Sign Out</a>
        </nav>
    </aside>
    
    <main class="main-content">
        <header class="mb-4">
            <h4 class="fw-bold m-0 text-white">Generate Performance Metrics</h4>
            <p style="color: var(--text-muted);" class="small m-0">Select a time-bound interval constraint boundary to pull logging audits.</p>
        </header>

        <div class="card report-card">
            <div class="d-flex align-items-center mb-4">
                <i class="bi bi-calendar-range fs-4 me-2" style="color: var(--accent-purple);"></i>
                <h5 class="fw-bold m-0 text-white">Time-Bound Audit Parameters</h5>
            </div>
            
            <form action="${pageContext.request.contextPath}/generateReport" method="GET">
                <div class="row g-3 mb-4">
                    <div class="col-12 col-sm-6">
                        <label class="form-label">Start Date Boundary</label>
                        <input type="date" name="startDate" class="form-control p-2.5 text-white" required>
                    </div>
                    <div class="col-12 col-sm-6">
                        <label class="form-label">End Date Boundary</label>
                        <input type="date" name="endDate" class="form-control p-2.5 text-white" required>
                    </div>
                </div>
                
                <button type="submit" class="btn btn-compile-logs w-100 py-2.5 rounded-3">
                    <i class="bi bi-lightning-charge-fill me-1"></i> Compile Query Logs
                </button>
            </form>
        </div>
                <div class="card report-card mt-4">
            <div class="d-flex align-items-center mb-3">
                <i class="bi bi-people-fill fs-3 me-3" style="color: #2DD4BF;"></i>
                <h5 class="fw-bold text-dark m-0">Master Directory Audit</h5>
            </div>
            <div class="card report-card mt-4">
                <div class="d-flex align-items-center mb-3">
                    <i class="bi bi-person-badge-fill fs-3 me-3" style="color: #EF4444;"></i>
                    <h5 class="fw-bold text-dark m-0">Personal Account Record</h5>
                </div>
                <p class="text-muted small mb-4">
                    Generates a landscape PDF containing only your personal administrator account details and system history.
                </p>
                <a href="${pageContext.request.contextPath}/generateReport?action=selfReport" class="btn w-100 py-2.5 rounded-3 fw-bold shadow-sm" style="background-color: #EF4444; color: #fff; border: none;">
                    <i class="bi bi-file-earmark-pdf-fill me-1"></i> Download My Record
                </a>
            </div>
            <p class="text-muted small mb-4">
                Generates a complete landscape PDF of all system accounts, decoded passwords, and complete certification histories. 
                <span class="text-danger fw-bold d-block mt-1">Highly Confidential. Handled with explicit administrative clearance only.</span>
            </p>
            <a href="${pageContext.request.contextPath}/generateReport?action=allUsers" class="btn w-100 py-2.5 rounded-3 fw-bold shadow-sm" style="background-color: #2DD4BF; color: #fff; border: none;">
                <i class="bi bi-file-earmark-pdf-fill me-1"></i> Download Master Report
            </a>
        </div>
        <div class="card report-card mt-4 mb-5">
            <div class="d-flex align-items-center mb-3">
                <i class="bi bi-award-fill fs-3 me-3" style="color: #F59E0B;"></i>
                <h5 class="fw-bold text-dark m-0">Batch Certificate Export</h5>
            </div>
            <p class="text-muted small mb-4">
                Executes a system-wide query to generate official printable certificate cards for every passed exam in the database.
            </p>
            <a href="${pageContext.request.contextPath}/generateReport?action=printCertificates" class="btn w-100 py-2.5 rounded-3 fw-bold shadow-sm" style="background-color: #F59E0B; color: #fff; border: none;">
                <i class="bi bi-printer-fill me-1"></i> Run Batch Print
            </a>
        </div>
    </main>
</body>
</html>