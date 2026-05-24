<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Examination Interface</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: #f8f9fa;
            min-height: 100vh;
            padding-top: 90px;
            user-select: none; /* Prevents copy-pasting during exam */
        }
        
        .exam-header {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            height: 75px;
            background-color: #ffffff;
            border-bottom: 1px solid #e2e8f0;
            z-index: 1030;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 2rem;
        }

        .question-card {
            background: #ffffff;
            border: none;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.02);
            padding: 2.5rem;
            margin-bottom: 1.5rem;
            min-height: 380px;
        }

        /* Custom Interactive Choice Option Rows */
        .option-container {
            display: flex;
            align-items: center;
            position: relative;
            padding: 1.1rem 1.1rem 1.1rem 3.5rem;
            margin-bottom: 0.85rem;
            cursor: pointer;
            background-color: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            font-weight: 500;
            color: #334155;
            transition: all 0.15s ease;
        }

        .option-container:hover {
            background-color: #f8fafc;
            border-color: #cbd5e1;
        }

        .option-container input {
            position: absolute;
            opacity: 0;
            cursor: pointer;
        }

        .checkmark {
            position: absolute;
            top: 50%;
            left: 1.35rem;
            transform: translateY(-50%);
            height: 22px;
            width: 22px;
            background-color: #fff;
            border: 2px solid #cbd5e1;
            border-radius: 50%;
            transition: all 0.15s ease;
        }

        /* Dynamic Checked Active UI Classes */
        .option-container.active-selected {
            border-color: #8B5CF6;
            background-color: #f9f5ff;
            color: #5b21b6;
            font-weight: 600;
        }

        .option-container.active-selected .checkmark {
            border-color: #8B5CF6;
            background-color: #8B5CF6;
        }

        .option-container.active-selected .checkmark::after {
            content: "";
            position: absolute;
            top: 5px;
            left: 5px;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: white;
        }

        /* Question Sidebar Selection Grid Box */
        .nav-grid-box {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            border: 1px solid #e2e8f0;
            background-color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 0.9rem;
            color: #64748b;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
        }

        .nav-grid-box:hover {
            border-color: #8B5CF6;
            color: #8B5CF6;
            background-color: #f9f5ff;
        }

        .nav-grid-box.current {
            border-color: #8B5CF6;
            box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.25);
            color: #8B5CF6;
            background-color: #f9f5ff;
        }

        .nav-grid-box.answered {
            background-color: #8B5CF6;
            border-color: #8B5CF6;
            color: #ffffff;
        }
        
        .nav-grid-box.answered.current {
            box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.4);
        }
    </style>
</head>
<body>

    <header class="exam-header shadow-sm">
        <div class="d-flex align-items-center">
            <span class="badge bg-danger-subtle text-danger fw-bold me-3 px-3 py-2 text-uppercase">Midterm Exam</span>
            <h5 class="fw-bold m-0 text-dark">ICS2609: Advanced Database Systems</h5>
        </div>
        <div class="d-flex align-items-center bg-dark text-white px-3 py-2 rounded-3">
            <i class="bi bi-clock-fill text-warning me-2"></i>
            <span class="fw-bold" id="timerDisplay">01:30:00</span>
        </div>
    </header>

    <div class="container main-container mt-4">
        <div class="row g-4">
            
            <main class="col-12 col-lg-8">
                <div class="card question-card">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <span class="text-muted small fw-bold text-uppercase" id="questionProgressText">Question 1 of 4</span>
                        <span class="badge bg-light text-muted border" id="questionPoints">Points: 2.0</span>
                    </div>
                    
                    <h5 class="fw-bold text-dark mb-4" id="questionTitleText">Loading Question Prompt...</h5>
                    
                    <div id="choicesBlockContainer">
                        </div>
                </div>

                <div class="d-flex justify-content-between align-items-center mt-3 mb-5">
                    <button type="button" class="btn btn-outline-secondary px-4 py-2 rounded-3 fw-semibold" id="prevBtn" onclick="navigateQuestion(-1)">
                        <i class="bi bi-arrow-left me-2"></i> Previous
                    </button>
                    <button type="button" class="btn btn-primary px-4 py-2 rounded-3 fw-semibold" id="nextBtn" style="background-color: #8B5CF6; border-color: #8B5CF6;" onclick="navigateQuestion(1)">
                        Next Question <i class="bi bi-arrow-right ms-2"></i>
                    </button>
                </div>
            </main>

            <aside class="col-12 col-lg-4">
                <div class="card border-0 shadow-sm rounded-4 p-4 sticky-top" style="top: 105px;">
                    <h6 class="fw-bold text-dark mb-3">Examination Navigation Overview</h6>
                    
                    <div class="d-flex flex-wrap gap-2 mb-4" id="navigationGridMatrix">
                        </div>
                    
                    <hr class="text-muted my-3">
                    
                    <form id="finalExamSubmissionForm" action="SubmitExamServlet" method="POST">
                        <input type="hidden" name="serializedAnswers" id="serializedAnswersInput">
                        <button type="button" class="btn btn-danger w-100 py-2.5 rounded-3 fw-bold shadow-sm" onclick="triggerExamSubmissionAlert()">
                            <i class="bi bi-send-fill me-2"></i> Submit Examination Paper
                        </button>
                    </form>
                </div>
            </aside>

        </div>
    </div>

    <script>
        // 1. Array Matrix containing Question Objects (Stephen can expand this easily)
        const examQuestions = [
            {
                id: 1,
                points: "2.0",
                text: "Which of the following ACID properties ensures that a concurrent database transaction execution sequence leaves the system database in a valid structural state?",
                options: { A: "Atomicity", B: "Consistency", C: "Isolation", D: "Durability" }
            },
            {
                id: 2,
                points: "2.0",
                text: "What isolation level prevents dirty reads but allows non-repeatable reads to occur within active execution instances?",
                options: { A: "Read Uncommitted", B: "Read Committed", C: "Repeatable Read", D: "Serializable" }
            },
            {
                id: 3,
                points: "2.0",
                text: "In a PostgreSQL environment, what structural protocol architecture design is primarily utilized to handle write concurrency conflicts cleanly without locks?",
                options: { A: "Two-Phase Locking (2PL)", B: "Write-Ahead Logging (WAL)", C: "Multi-Version Concurrency Control (MVCC)", D: "Query Execution Optimization" }
            },
            {
                id: 4,
                points: "4.0",
                text: "Which storage engine framework serves as the native local user table component environment when deploying Apache Derby embedded client configurations?",
                options: { A: "InnoDB Engine Cluster", B: "Derby Core Falcon Storage Engine", C: "Pluggable Disk Database Engine Component", D: "SQLite VFS Mapping Layer" }
            }
        ];

        // 2. Local State Variables Keep Track of User Progress Tracking Matrix 
        let currentQuestionIndex = 0;
        let selectedAnswersLog = {}; // Stores key-value tracking properties (e.g., {1: 'B', 2: 'A'})
        let totalExamTimeSeconds = 90 * 60; // 90 Minutes Total Countdown Duration Assignment

        // 3. Initialize Layout Elements Once Content View Model Is Mount Confirmed
        window.addEventListener('DOMContentLoaded', () => {
            renderSidebarNavigationGrid();
            displayActiveQuestionCard();
            startCountdownTimer();
        });

        // 4. Generate the Sidebar Tracking Box Elements Dynamically
        function renderSidebarNavigationGrid() {
            const gridContainer = document.getElementById('navigationGridMatrix');
            gridContainer.innerHTML = '';
            
            examQuestions.forEach((question, index) => {
                const box = document.createElement('a');
                box.className = 'nav-grid-box';
                box.id = `nav-box-${index}`;
                box.innerText = question.id;
                
                // Add event trigger logic allowing quick jumps by clicking numbers
                box.onclick = () => jumpToQuestion(index);
                gridContainer.appendChild(box);
            });
            updateSidebarHighlightStates();
        }

        // 5. Update Question Fields and Input Nodes Inside Left Panel Card Section
        function displayActiveQuestionCard() {
            const currentQuestion = examQuestions[currentQuestionIndex];
            
            // Map text updates safely 
            document.getElementById('questionProgressText').innerText = `Question ${currentQuestionIndex + 1} of ${examQuestions.length}`;
            document.getElementById('questionPoints').innerText = `Points: ${currentQuestion.points}`;
            document.getElementById('questionTitleText').innerText = currentQuestion.text;
            
            // Build the option radio choice tree components cleanly
            const choicesContainer = document.getElementById('choicesBlockContainer');
            choicesContainer.innerHTML = '';
            
            Object.entries(currentQuestion.options).forEach(([key, val]) => {
                const label = document.createElement('label');
                label.className = 'option-container';
                
                const isChecked = selectedAnswersLog[currentQuestion.id] === key;
                if (isChecked) {
                    label.classList.add('active-selected');
                }
                
                label.innerHTML = `
                    <input type="radio" name="currentQuestionChoice" value="${key}" ${isChecked ? 'checked' : ''} onchange="logUserChoiceSelection('${currentQuestion.id}', '${key}')">
                    <span class="checkmark"></span>
                    ${key}. ${val}
                `;
                
                choicesContainer.appendChild(label);
            });
            
            // Sync active state indicators on interface action elements
            document.getElementById('prevBtn').disabled = (currentQuestionIndex === 0);
            if (currentQuestionIndex === examQuestions.length - 1) {
                document.getElementById('nextBtn').innerHTML = `Review Summary <i class="bi bi-journal-check ms-2"></i>`;
            } else {
                document.getElementById('nextBtn').innerHTML = `Next Question <i class="bi bi-arrow-right ms-2"></i>`;
            }
            
            updateSidebarHighlightStates();
        }

        // 6. Monitor and Log Selection Matrix Changes Locally
        function logUserChoiceSelection(questionId, selectedChoiceLetter) {
            selectedAnswersLog[questionId] = selectedChoiceLetter;
            
            // Visual accent feedback styling trigger logic
            const containers = document.querySelectorAll('.option-container');
            containers.forEach(item => item.classList.remove('active-selected'));
            
            const checkedInput = document.querySelector('input[name="currentQuestionChoice"]:checked');
            if (checkedInput) {
                checkedInput.parentElement.classList.add('active-selected');
            }
            
            updateSidebarHighlightStates();
        }

        // 7. Synchronize Color Accents on Right-Side Grid Layout Component Box Modules
        function updateSidebarHighlightStates() {
            examQuestions.forEach((question, index) => {
                const box = document.getElementById(`nav-box-${index}`);
                if (!box) return;
                
                box.className = 'nav-grid-box'; // reset class template values
                
                if (selectedAnswersLog[question.id]) {
                    box.classList.add('answered');
                }
                if (index === currentQuestionIndex) {
                    box.classList.add('current');
                }
            });
        }

        // 8. Control Prev/Next Button Iteration Logic Flows
        function navigateQuestion(directionOffset) {
            const targetIndex = currentQuestionIndex + directionOffset;
            if (targetIndex >= 0 && targetIndex < examQuestions.length) {
                currentQuestionIndex = targetIndex;
                displayActiveQuestionCard();
            }
        }

        function jumpToQuestion(targetIndex) {
            currentQuestionIndex = targetIndex;
            displayActiveQuestionCard();
        }

        // 9. Process Countdown Expiration Variables and Clock String Formatting 
        function startCountdownTimer() {
            const display = document.getElementById('timerDisplay');
            
            const internalTimerInterval = setInterval(() => {
                let hours = Math.floor(totalExamTimeSeconds / 3600);
                let minutes = Math.floor((totalExamTimeSeconds % 3600) / 60);
                let seconds = totalExamTimeSeconds % 60;
                
                hours = hours < 10 ? '0' + hours : hours;
                minutes = minutes < 10 ? '0' + minutes : minutes;
                seconds = seconds < 10 ? '0' + seconds : seconds;
                
                display.innerText = `${hours}:${minutes}:${seconds}`;
                
                if (--totalExamTimeSeconds < 0) {
                    clearInterval(internalTimerInterval);
                    display.innerText = "00:00:00";
                    alert("Time has officially expired! Your exam will save automatically.");
                    triggerExamSubmissionAlert();
                }
            }, 1000);
        }

        // 10. Package Log Values and Fire to Servlet Controller Configuration
        function triggerExamSubmissionAlert() {
            const totalAnswered = Object.keys(selectedAnswersLog).length;
            const confirmationResponse = confirm(`You have answered ${totalAnswered} out of ${examQuestions.length} questions. Are you completely sure you want to lock in your answers and submit your exam layout paper?`);
            
            if (confirmationResponse) {
                // Stringify choices matrix array log values and push to backend parameter layer
                document.getElementById('serializedAnswersInput').value = JSON.stringify(selectedAnswersLog);
                document.getElementById('finalExamSubmissionForm').submit();
            }
        }
    </script>
</body>
</html>