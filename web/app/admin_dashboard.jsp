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
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Plus+Jakarta+Sans:wght@600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            /* NexaFlow Premium Admin Palette */
            --bg-gradient: radial-gradient(circle at 50% 0%, #1a103c 0%, #000000 100%);
            --card-bg: rgba(26, 18, 44, 0.6);
            --sidebar-bg: #070512;
            /* Accents */
            --accent-purple: #8B5CF6;
            --accent-teal: #2DD4BF;
            --border-glass: rgba(255, 255, 255, 0.05);
            --border-glass-top: rgba(255, 255, 255, 0.12);
            /* High Contrast Text Visibility Rules */
            --text-heading: #ffffff;
            --text-body: #cbd5e1;
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

        /* Subtle SVG Noise Overlay */
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

        /* Bento Admin Cards Architecture with Managed Glow */
        .bento-card {
            background: var(--card-bg);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid var(--border-glass);
            border-top: 1px solid var(--border-glass-top);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
            padding: 2.25rem;
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .bento-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.5), 0 0 25px rgba(139, 92, 246, 0.05);
        }

        /* Premium Minimalist Control Buttons */
        .btn-action-panel {
            background-color: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--border-glass);
            border-radius: 10px;
            padding: 0.6rem 1.2rem;
            font-size: 0.9rem;
            font-weight: 600;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }

        .btn-action-panel.purple-glow {
            color: #c4b5fd;
        }

        .btn-action-panel.purple-glow:hover {
            background-color: var(--accent-purple);
            color: #ffffff;
            box-shadow: 0 0 15px rgba(139, 92, 246, 0.4);
        }

        .btn-action-panel.teal-glow {
            color: #a7f3d0;
        }

        .btn-action-panel.teal-glow:hover {
            background-color: var(--accent-teal);
            color: #000000;
            box-shadow: 0 0 15px rgba(45, 212, 191, 0.4);
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
            <a class="nav-link-custom active" href="#"><i class="bi bi-sliders"></i> Control Center</a>
            <a class="nav-link-custom" href="${pageContext.request.contextPath}/app/reports.jsp"><i class="bi bi-file-earmark-bar-graph-fill"></i> System Reports</a>
            <hr class="mx-3 opacity-20" style="color: var(--text-body);">
            <a class="nav-link-custom text-danger" href="logout"><i class="bi bi-box-arrow-left"></i> Sign Out</a>
        </nav>
    </aside>

    <main class="main-content">
        <header class="mb-4">
            <h4 class="fw-bold m-0 text-white">System Administration Panel</h4>
            <p style="color: var(--text-muted);" class="small m-0">Monitor accounts and run date-bound performance audits.</p>
        </header>

        <section class="row g-4 mb-4">
            <div class="col-12 col-md-6">
                <div class="card bento-card">
                    <div>
                        <div class="d-flex align-items-center mb-3">
                            <i class="bi bi-people-fill fs-4 me-2" style="color: var(--accent-purple);"></i>
                            <h5 class="fw-bold m-0 text-white">User System Accounts</h5>
                        </div>
                        <p style="color: var(--text-body);" class="small lh-base opacity-75">View, provision, audit, or restrict active student and faculty nodes across the directory repository mapping.</p>
                    </div>
                    <div class="mt-4">
                        <a href="${pageContext.request.contextPath}/directory" class="btn-action-panel purple-glow w-50">View Directory →</a>
                    </div>
                </div>
            </div>

            <div class="col-12 col-md-6">
                <div class="card bento-card">
                    <div>
                        <div class="d-flex align-items-center mb-3">
                            <i class="bi bi-cpu-fill fs-4 me-2" style="color: var(--accent-teal);"></i>
                            <h5 class="fw-bold m-0 text-white">Report Engine Center</h5>
                        </div>
                        <p style="color: var(--text-body);" class="small lh-base opacity-75">Configure date range metrics to evaluate internal metrics sheets, track student paths, and log system audits instantly.</p>
                    </div>
                    <div class="mt-4">
                        <a href="${pageContext.request.contextPath}/app/reports.jsp" class="btn-action-panel teal-glow w-50">Open Reports Form →</a>
                    </div>
                </div>
            </div>
        </section>
    </main>
</body>
</html>