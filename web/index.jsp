<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="tools.User" %>
<%
    // Check if the user is already authenticated
    if (session != null && session.getAttribute("currentUser") != null) {
        // Redirect them to the HomeServlet, which handles dashboard routing automatically
        response.sendRedirect(request.getContextPath() + "/home");
        return; // Stop processing the rest of index.jsp
    }
%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Plus+Jakarta+Sans:wght@600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            /* NexaFlow Deep Dark Palette */
            --bg-gradient: radial-gradient(circle at 50% 50%, #2e1065 0%, #000000 100%);
            --card-bg: rgba(18, 12, 32, 0.65);
            --accent-purple: #8B5CF6;
            --accent-purple-glow: rgba(139, 92, 246, 0.15);
            --border-glass: rgba(255, 255, 255, 0.08);
            --border-glass-top: rgba(255, 255, 255, 0.18);
            /* High Contrast Text Definitions */
            --text-heading: #ffffff;
            --text-body: #e2e8f0;
            --text-muted: #94a3b8;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-gradient);
            background-attachment: fixed;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
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

        .container {
            position: relative;
            z-index: 2;
        }

        h2 {
            font-family: 'Plus Jakarta Sans', sans-serif;
            letter-spacing: -0.02em;
            color: var(--text-heading) !important;
        }

        /* NexaFlow Refined Floating Card with Underglow & Glass Lip */
        .login-card {
            border: 1px solid var(--border-glass);
            border-top: 1px solid var(--border-glass-top); /* Glass Lip upper shadow */
            border-radius: 20px;
            background: var(--card-bg);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.7), 0 0 40px var(--accent-purple-glow); /* Managed, non-blinding underglow */
        }

        /* Input Elements High-Contrast Dark Refactoring */
        .form-label {
            color: var(--text-body);
            font-size: 0.85rem;
            font-weight: 500;
            margin-bottom: 0.5rem;
        }

        .input-group-text {
            background-color: rgba(15, 10, 28, 0.6) !important;
            border: 1px solid var(--border-glass) !important;
            border-right: none !important;
            color: var(--text-muted) !important;
            border-radius: 12px 0 0 12px !important;
            padding: 0.75rem 1rem;
        }

        .form-control {
            background-color: rgba(15, 10, 28, 0.4) !important;
            border: 1px solid var(--border-glass) !important;
            border-left: none !important;
            color: var(--text-heading) !important;
            border-radius: 0 12px 12px 0 !important;
            padding: 0.75rem 1rem;
            font-size: 0.95rem;
            transition: all 0.2s ease;
        }

        .form-control::placeholder {
            color: #4b5563 !important;
        }

        /* Clean High Contrast Validation State focus toggles */
        .form-control:focus {
            border-color: var(--accent-purple) !important;
            box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.25) !important;
        }

        /* Academic Premium Purple Button Configuration */
        .btn-primary {
            background-color: var(--accent-purple);
            border: 1px solid rgba(255, 255, 255, 0.1);
            font-weight: 600;
            font-size: 0.95rem;
            padding: 0.8rem;
            border-radius: 12px;
            transition: all 0.2s ease;
            box-shadow: 0 4px 12px rgba(139, 92, 246, 0.25);
        }

        .btn-primary:hover {
            background-color: #7c3aed;
            box-shadow: 0 6px 20px rgba(139, 92, 246, 0.4);
            transform: translateY(-1px);
        }

        /* Elegant Frame Containers for Dynamic Warnings */
        .alert-danger {
            background-color: rgba(239, 68, 68, 0.1) !important;
            border: 1px solid rgba(239, 68, 68, 0.2) !important;
            color: #fca5a5 !important;
            border-radius: 12px;
            font-size: 0.9rem;
        }

        /* Custom text color override for the internal bootstrap feedbacks */
        .invalid-feedback {
            color: #fca5a5 !important;
            font-size: 0.8rem;
            margin-top: 0.35rem;
        }

        /* Integrated reCAPTCHA Dark Theme Shell Frame wrapper */
        .recaptcha-wrapper {
            background: rgba(0, 0, 0, 0.2);
            padding: 6px;
            border-radius: 10px;
            border: 1px solid var(--border-glass);
            display: inline-block;
        }
    </style>
    <script src="https://www.google.com/recaptcha/api.js" async defer></script>
</head>
<body>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-12 col-sm-10 col-md-8 col-lg-5">
                <div class="card login-card p-4 p-md-5">
                    <div class="text-center mb-4">
                        <div class="d-inline-flex align-items-center justify-content-center bg-dark rounded-circle p-3 mb-3" style="width: 56px; height: 56px; color: var(--accent-purple) !important; border: 1px solid var(--border-glass);">
                            <i class="bi bi-shield-lock-fill fs-4"></i>
                        </div>
                        <h2 class="fw-bold m-0">Welcome Back</h2>
                        <p style="color: var(--text-muted);" class="small mt-1">Please sign in to access your dashboard</p>
                    </div>

                    <% if (request.getAttribute("errorMessage") != null) { %>
                        <div class="alert alert-danger d-flex align-items-center mb-4" role="alert">
                            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
                            <div><%= request.getAttribute("errorMessage") %></div>
                        </div>
                    <% } %>

                    <form id="loginForm" action="home" method="POST" class="needs-validation" novalidate>
                        <div class="mb-3">
                            <label for="username" class="form-label">Username</label>
                            <div class="input-group">
                                <span class="input-group-text" id="username-addon"><i class="bi bi-person"></i></span>
                                <input type="text" id="username" name="username" class="form-control" placeholder="Enter your username" required autocomplete="off">
                                <div class="invalid-feedback">Username is required.</div>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label for="password" class="form-label">Password</label>
                            <div class="input-group">
                                <span class="input-group-text" id="password-addon"><i class="bi bi-key"></i></span>
                                <input type="password" id="password" name="password" class="form-control" placeholder="********" required>
                                <div class="invalid-feedback">Password is required.</div>
                            </div>
                        </div>

                        <div class="mb-4 d-flex justify-content-center">
                            <div class="recaptcha-wrapper shadow-sm">
                                <div class="g-recaptcha" data-theme="dark" data-sitekey="6LfR17osAAAAAPbAHLNDt_1tKx2wz590ktorCjxZ" data-callback="recaptchaCallback"></div>
                            </div>
                        </div>

                        <div id="captcha-error" class="small text-center mb-3 d-none" style="color: #fca5a5; font-weight: 500;">
                            <i class="bi bi-robot me-1"></i> Please verify that you are not a robot.
                        </div>

                        <button type="submit" class="btn btn-primary w-100 text-white shadow-sm">
                            Sign In <i class="bi bi-arrow-right ms-2"></i>
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        let isCaptchaValidated = false;

        function recaptchaCallback() {
            isCaptchaValidated = true;
            document.getElementById('captcha-error').classList.add('d-none');
        }

        document.getElementById('loginForm').addEventListener('submit', function (event) {
            const form = this;
            const captchaError = document.getElementById('captcha-error');

            if (!form.checkValidity() || !isCaptchaValidated) {
                event.preventDefault();
                event.stopPropagation();

                if (!isCaptchaValidated) {
                    captchaError.classList.remove('d-none');
                }
            }
            form.classList.add('was-validated');
        }, false);
        window.addEventListener('pageshow', function (event) {
                if (event.persisted) {
                    window.location.reload();
                }
            });
    </script>
</body>
</html>