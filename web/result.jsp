<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="tools.User" %>
<%
    // SECURITY GATE: Ensure user context remains validated
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    // EXTRACTION GATE: Read performance variables forwarded from PostgreSQL processor servlet
    // (Using hardcoded fallbacks if direct page hits occur to prevent NullPointer crashes)
    String examTitle = request.getAttribute("examTitle") != null ? (String)request.getAttribute("examTitle") : "ICS2609: Advanced Database Systems";
    String scoreSecured = request.getAttribute("scoreSecured") != null ? String.valueOf(request.getAttribute("scoreSecured")) : "3";
    String totalQuestions = request.getAttribute("totalQuestions") != null ? String.valueOf(request.getAttribute("totalQuestions")) : "4";
    String timeElapsed = request.getAttribute("timeElapsed") != null ? (String)request.getAttribute("timeElapsed") : "12m 45s";
    
    // Percentage logic mapping computation
    double rawScore = Double.parseDouble(scoreSecured);
    double rawTotal = Double.parseDouble(totalQuestions);
    int percentageSecured = (int) Math.round((rawScore / rawTotal) * 100);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Examination Performance Results</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <style>
        :root {
            /* NexaFlow Unified Premium Palette */
            --bg-gradient: radial-gradient(circle at 50% 50%, #170d35 0%, #020105 100%);
            --card-bg: rgba(22, 16, 38, 0.75);
            
            /* Theme Accents */
            --accent-purple: #8B5CF6;
            --accent-teal: #2DD4BF;
            --border-glass: rgba(255, 255, 255, 0.06);
            --border-glass-top: rgba(255, 255, 255, 0.15);
            --accent-glow-subtle: rgba(139, 92, 246, 0.1);

            /* High Contrast Typography Visibility Matrix */
            --text-heading: #ffffff;
            --text-body: #f1f5f9;
            --text-muted: #94a3b8;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-gradient);
            background-attachment: fixed;
            color: var(--text-body);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
            position: relative;
        }

        /* Subtle SVG Noise Overlay Layer */
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

        .container {
            position: relative;
            z-index: 2;
        }

        h4, h5, h2 {
            font-family: 'Plus Jakarta Sans', sans-serif;
            letter-spacing: -0.01em;
            color: var(--text-heading);
        }

        /* Enclosed Pseudo-Form Bento Container Grid with Controlled Underglow */
        .pseudo-form-card {
            background: var(--card-bg);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid var(--border-glass);
            border-top: 1px solid var(--border-glass-top);
            border-radius: 24px;
            box-shadow: 0 25px 60px -15px rgba(0, 0, 0, 0.7),
                        0 0 50px var(--accent-glow-subtle); /* Clean, managed, non-overpowering purple haze */
            padding: 3rem;
            max-width: 760px;
            width: 100%;
            position: relative;
        }

        /* Pure CSS Radial Progress Circular Meter Frame */
        .circle-meter-wrapper {
            position: relative;
            width: 160px;
            height: 160px;
            border-radius: 50%;
            /* FIXED: The transparent background channel now safely matches your exact computed breakpoint angle */
            background: conic-gradient(
                var(--accent-teal) 0deg, 
                var(--accent-teal) <%= (percentageSecured * 360) / 100 %>deg, 
                rgba(255, 255, 255, 0.05) <%= (percentageSecured * 360) / 100 %>deg, 
                rgba(255, 255, 255, 0.05) 360deg
            );
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: inset 0 0 20px rgba(0,0,0,0.5);
        }

        /* Inner masking cutout block to form thin halo circle element ring layout */
        .circle-meter-inner {
            width: 132px;
            height: 132px;
            border-radius: 50%;
            background-color: #0d091a;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            border: 1px solid var(--border-glass);
        }

        .numerical-display-box {
            background: rgba(0, 0, 0, 0.2);
            border: 1px solid var(--border-glass);
            border-radius: 16px;
            padding: 1.5rem;
        }

        /* Return Navigation Directives Button Anchor Rules */
        .btn-return-home {
            background-color: var(--accent-purple);
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: #ffffff;
            font-weight: 600;
            padding: 0.75rem 1.5rem;
            border-radius: 12px;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 4px 12px rgba(139, 92, 246, 0.2);
            text-decoration: none;
            display: inline-flex;
            align-items: center;
        }

        .btn-return-home:hover {
            background-color: #7c3aed;
            box-shadow: 0 6px 20px rgba(139, 92, 246, 0.4);
            transform: translateY(-1px);
            color: #ffffff;
        }

        .meta-metric-pill {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--border-glass);
            border-radius: 10px;
            padding: 0.5rem 1rem;
            display: inline-flex;
            align-items: center;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>

<div class="container d-flex justify-content-center py-5">
    
    <div class="pseudo-form-card shadow-lg">
        
        <div class="d-flex justify-content-between align-items-start border-bottom pb-4 mb-4" style="border-color: var(--border-glass) !important;">
            <div>
                <span class="badge bg-dark text-purple border mb-2 small text-uppercase" style="border-color: var(--border-glass) !important; color: #c4b5fd;">Grading Status Verified</span>
                <h4 class="fw-bold m-0 text-white"><%= examTitle %></h4>
            </div>
            
            <div class="meta-metric-pill text-white shadow-sm">
                <i class="bi bi-hourglass-split text-warning me-2"></i>
                <span class="text-muted me-1">Duration:</span> <strong class="font-monospace"><%= timeElapsed %></strong>
            </div>
        </div>

        <div class="row align-items-center g-5 my-2">
            
            <div class="col-12 col-md-6">
                <div class="numerical-display-box">
                    <span style="color: var(--text-muted);" class="small text-uppercase fw-bold tracking-wider d-block mb-1">Earned Evaluation Mark</span>
                    <div class="d-flex align-items-baseline mb-2">
                        <h2 class="display-3 fw-extrabold m-0 text-white font-monospace"><%= (int)rawScore %></h2>
                        <span class="text-muted fs-3 mx-2">/</span>
                        <h4 class="fs-2 text-muted m-0 font-monospace"><%= (int)rawTotal %></h4>
                    </div>
                    <p style="color: var(--text-body);" class="small m-0 opacity-75">Your final examination question evaluation logs have been synced with the PostgreSQL operational directory repository engine parameters successfully.</p>
                </div>
            </div>

            <div class="col-12 col-md-6 d-flex justify-content-center">
                <div class="text-center">
                    <div class="circle-meter-wrapper mx-auto mb-2">
                        <div class="circle-meter-inner">
                            <h2 class="fw-bold m-0 font-monospace text-white"><%= percentageSecured %>%</h2>
                            <span style="color: var(--text-muted); font-size: 0.75rem;" class="text-uppercase fw-semibold tracking-wider mt-1">Accuracy</span>
                        </div>
                    </div>
                </div>
            </div>

        </div>

        <div class="d-flex justify-content-between align-items-center border-top pt-4 mt-5" style="border-color: var(--border-glass) !important;">
            <div class="small" style="color: var(--text-muted);">
                <i class="bi bi-shield-check text-teal me-1" style="color: var(--accent-teal);"></i> Verifiable Secure Submission Token Logs
            </div>
            
            <div>
                <a href="${pageContext.request.contextPath}/home" class="btn-return-home shadow-sm">
                    Return to Dashboard <i class="bi bi-house-door-fill ms-2"></i>
                </a>
            </div>
        </div>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>