# Chatbot and Planner Use Case Diagram HTML

Here is the full HTML content for the use case diagram. You can copy this code and save it as `chatbot_planner_use_case_diagram.html`.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Athena: Chatbot & Study Planner Use Case Diagram</title>
    <style>
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }

      body {
        font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh;
        padding: 20px;
      }

      .container {
        max-width: 1600px;
        margin: 0 auto;
        background: white;
        border-radius: 20px;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        overflow: hidden;
      }

      .header {
        background: linear-gradient(135deg, #6b46c1 0%, #8b5cf6 100%);
        color: white;
        padding: 30px;
        text-align: center;
      }

      .header h1 {
        font-size: 2.5rem;
        font-weight: 700;
        margin-bottom: 10px;
      }

      .header p {
        font-size: 1.2rem;
        opacity: 0.9;
      }

      .diagram-container {
        padding: 40px;
        background: #f8fafc;
      }

      .svg-wrapper {
        background: white;
        border-radius: 15px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        padding: 20px;
        margin-bottom: 40px;
      }

      svg {
        width: 100%;
        height: auto;
        display: block;
      }

      .documentation {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
        gap: 30px;
        margin-top: 40px;
      }

      .doc-section {
        background: white;
        border-radius: 15px;
        padding: 25px;
        box-shadow: 0 5px 20px rgba(0, 0, 0, 0.08);
        border-left: 5px solid #6b46c1;
      }

      .doc-section h3 {
        color: #6b46c1;
        font-size: 1.4rem;
        margin-bottom: 15px;
        display: flex;
        align-items: center;
        gap: 10px;
      }

      .doc-section ul {
        list-style: none;
      }

      .doc-section li {
        margin-bottom: 10px;
        padding: 8px 12px;
        background: #f1f5f9;
        border-radius: 8px;
        font-size: 0.95rem;
        line-height: 1.4;
      }

      .use-case-id {
        color: #8b5cf6;
        font-weight: bold;
      }

      .actor-section {
        border-left-color: #059669;
      }

      .actor-section h3 {
        color: #059669;
      }

      .relationship-section {
        border-left-color: #dc2626;
      }

      .relationship-section h3 {
        color: #dc2626;
      }

      .tech-section {
        border-left-color: #f59e0b;
      }

      .tech-section h3 {
        color: #f59e0b;
      }

      .footer {
        background: #1e293b;
        color: white;
        padding: 20px;
        text-align: center;
        font-size: 0.9rem;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <header class="header">
        <h1>🤖 Athena: AI Study Companion</h1>
        <p>Chatbot & Study Planner Use Case Diagram</p>
      </header>

      <div class="diagram-container">
        <div class="svg-wrapper">
          <svg viewBox="0 0 1400 1000" xmlns="http://www.w3.org/2000/svg">
            <!-- Definitions for arrows and gradients -->
            <defs>
              <marker
                id="arrowhead"
                markerWidth="10"
                markerHeight="7"
                refX="9"
                refY="3.5"
                orient="auto"
              >
                <polygon points="0 0, 10 3.5, 0 7" fill="#374151" />
              </marker>
              <linearGradient
                id="chatbotGradient"
                x1="0%"
                y1="0%"
                x2="100%"
                y2="100%"
              >
                <stop offset="0%" style="stop-color:#EDE9FE" />
                <stop offset="100%" style="stop-color:#DDD6FE" />
              </linearGradient>
              <linearGradient
                id="plannerGradient"
                x1="0%"
                y1="0%"
                x2="100%"
                y2="100%"
              >
                <stop offset="0%" style="stop-color:#DCFCE7" />
                <stop offset="100%" style="stop-color:#BBF7D0" />
              </linearGradient>
            </defs>

            <!-- System Boundaries -->
            <!-- Chatbot System -->
            <rect
              x="200"
              y="100"
              width="550"
              height="380"
              fill="none"
              stroke="#6B46C1"
              stroke-width="3"
              rx="10"
            />
            <text
              x="475"
              y="85"
              text-anchor="middle"
              font-size="18"
              font-weight="bold"
              fill="#6B46C1"
            >
              🤖 AI Chatbot System
            </text>

            <!-- Study Planner System -->
            <rect
              x="200"
              y="520"
              width="550"
              height="350"
              fill="none"
              stroke="#059669"
              stroke-width="3"
              rx="10"
            />
            <text
              x="475"
              y="505"
              text-anchor="middle"
              font-size="18"
              font-weight="bold"
              fill="#059669"
            >
              📅 Study Planner System
            </text>

            <!-- Primary Actor - Student -->
            <g id="student">
              <circle
                cx="80"
                cy="450"
                r="25"
                fill="#FEF3C7"
                stroke="#F59E0B"
                stroke-width="3"
              />
              <line
                x1="80"
                y1="475"
                x2="80"
                y2="530"
                stroke="#374151"
                stroke-width="3"
              />
              <line
                x1="55"
                y1="500"
                x2="105"
                y2="500"
                stroke="#374151"
                stroke-width="3"
              />
              <line
                x1="80"
                y1="530"
                x2="60"
                y2="570"
                stroke="#374151"
                stroke-width="3"
              />
              <line
                x1="80"
                y1="530"
                x2="100"
                y2="570"
                stroke="#374151"
                stroke-width="3"
              />
              <text
                x="80"
                y="590"
                text-anchor="middle"
                font-size="14"
                font-weight="bold"
                fill="#374151"
              >
                Student
              </text>
            </g>

            <!-- Secondary Actors -->
            <!-- AI System -->
            <g id="ai-system">
              <circle
                cx="900"
                cy="250"
                r="25"
                fill="#DBEAFE"
                stroke="#3B82F6"
                stroke-width="3"
              />
              <line
                x1="900"
                y1="275"
                x2="900"
                y2="330"
                stroke="#374151"
                stroke-width="3"
              />
              <line
                x1="875"
                y1="300"
                x2="925"
                y2="300"
                stroke="#374151"
                stroke-width="3"
              />
              <line
                x1="900"
                y1="330"
                x2="880"
                y2="370"
                stroke="#374151"
                stroke-width="3"
              />
              <line
                x1="900"
                y1="330"
                x2="920"
                y2="370"
                stroke="#374151"
                stroke-width="3"
              />
              <text
                x="900"
                y="390"
                text-anchor="middle"
                font-size="14"
                font-weight="bold"
                fill="#374151"
              >
                AI System
              </text>
            </g>

            <!-- Notification System -->
            <g id="notification-system">
              <circle
                cx="900"
                cy="650"
                r="25"
                fill="#FEE2E2"
                stroke="#EF4444"
                stroke-width="3"
              />
              <line
                x1="900"
                y1="675"
                x2="900"
                y2="730"
                stroke="#374151"
                stroke-width="3"
              />
              <line
                x1="875"
                y1="700"
                x2="925"
                y2="700"
                stroke="#374151"
                stroke-width="3"
              />
              <line
                x1="900"
                y1="730"
                x2="880"
                y2="770"
                stroke="#374151"
                stroke-width="3"
              />
              <line
                x1="900"
                y1="730"
                x2="920"
                y2="770"
                stroke="#374151"
                stroke-width="3"
              />
              <text
                x="900"
                y="790"
                text-anchor="middle"
                font-size="14"
                font-weight="bold"
                fill="#374151"
              >
                Notification
              </text>
              <text
                x="900"
                y="805"
                text-anchor="middle"
                font-size="14"
                font-weight="bold"
                fill="#374151"
              >
                System
              </text>
            </g>

            <!-- Study Materials System -->
            <g id="materials-system">
              <circle
                cx="1200"
                cy="350"
                r="25"
                fill="#F3E8FF"
                stroke="#8B5CF6"
                stroke-width="3"
              />
              <line
                x1="1200"
                y1="375"
                x2="1200"
                y2="430"
                stroke="#374151"
                stroke-width="3"
              />
              <line
                x1="1175"
                y1="400"
                x2="1225"
                y2="400"
                stroke="#374151"
                stroke-width="3"
              />
              <line
                x1="1200"
                y1="430"
                x2="1180"
                y2="470"
                stroke="#374151"
                stroke-width="3"
              />
              <line
                x1="1200"
                y1="430"
                x2="1220"
                y2="470"
                stroke="#374151"
                stroke-width="3"
              />
              <text
                x="1200"
                y="490"
                text-anchor="middle"
                font-size="14"
                font-weight="bold"
                fill="#374151"
              >
                Study Materials
              </text>
              <text
                x="1200"
                y="505"
                text-anchor="middle"
                font-size="14"
                font-weight="bold"
                fill="#374151"
              >
                System
              </text>
            </g>

            <!-- CHATBOT USE CASES -->
            <!-- Primary Use Cases -->
            <ellipse
              cx="320"
              cy="160"
              rx="70"
              ry="30"
              fill="url(#chatbotGradient)"
              stroke="#6B46C1"
              stroke-width="2"
            />
            <text
              x="320"
              y="155"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Ask Academic
            </text>
            <text
              x="320"
              y="168"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Question
            </text>

            <ellipse
              cx="500"
              cy="160"
              rx="70"
              ry="30"
              fill="url(#chatbotGradient)"
              stroke="#6B46C1"
              stroke-width="2"
            />
            <text
              x="500"
              y="155"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Get Homework
            </text>
            <text
              x="500"
              y="168"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Help
            </text>

            <ellipse
              cx="620"
              cy="220"
              rx="70"
              ry="30"
              fill="url(#chatbotGradient)"
              stroke="#6B46C1"
              stroke-width="2"
            />
            <text
              x="620"
              y="215"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Ask Follow-up
            </text>
            <text
              x="620"
              y="228"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Question
            </text>

            <ellipse
              cx="420"
              cy="240"
              rx="70"
              ry="30"
              fill="url(#chatbotGradient)"
              stroke="#6B46C1"
              stroke-width="2"
            />
            <text
              x="420"
              y="235"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Query Study
            </text>
            <text
              x="420"
              y="248"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Notes (RAG)
            </text>

            <ellipse
              cx="250"
              cy="220"
              rx="65"
              ry="30"
              fill="url(#chatbotGradient)"
              stroke="#6B46C1"
              stroke-width="2"
            />
            <text
              x="250"
              y="215"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              View Chat
            </text>
            <text
              x="250"
              y="228"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              History
            </text>

            <!-- Secondary Use Cases -->
            <ellipse
              cx="250"
              cy="320"
              rx="65"
              ry="30"
              fill="url(#chatbotGradient)"
              stroke="#6B46C1"
              stroke-width="2"
            />
            <text
              x="250"
              y="315"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Create
            </text>
            <text
              x="250"
              y="328"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Conversation
            </text>

            <ellipse
              cx="380"
              cy="320"
              rx="60"
              ry="30"
              fill="url(#chatbotGradient)"
              stroke="#6B46C1"
              stroke-width="2"
            />
            <text
              x="380"
              y="315"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Upload
            </text>
            <text
              x="380"
              y="328"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Files
            </text>

            <ellipse
              cx="520"
              cy="320"
              rx="70"
              ry="30"
              fill="url(#chatbotGradient)"
              stroke="#6B46C1"
              stroke-width="2"
            />
            <text
              x="520"
              y="315"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Stream AI
            </text>
            <text
              x="520"
              y="328"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Response
            </text>

            <ellipse
              cx="620"
              cy="380"
              rx="70"
              ry="30"
              fill="url(#chatbotGradient)"
              stroke="#6B46C1"
              stroke-width="2"
            />
            <text
              x="620"
              y="375"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Manage
            </text>
            <text
              x="620"
              y="388"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Conversations
            </text>

            <!-- STUDY PLANNER USE CASES -->
            <ellipse
              cx="280"
              cy="580"
              rx="65"
              ry="30"
              fill="url(#plannerGradient)"
              stroke="#059669"
              stroke-width="2"
            />
            <text
              x="280"
              y="575"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Create Study
            </text>
            <text
              x="280"
              y="588"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Goal
            </text>

            <ellipse
              cx="420"
              cy="580"
              rx="75"
              ry="30"
              fill="url(#plannerGradient)"
              stroke="#059669"
              stroke-width="2"
            />
            <text
              x="420"
              y="575"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Schedule Study
            </text>
            <text
              x="420"
              y="588"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Session
            </text>

            <ellipse
              cx="580"
              cy="580"
              rx="60"
              ry="30"
              fill="url(#plannerGradient)"
              stroke="#059669"
              stroke-width="2"
            />
            <text
              x="580"
              y="575"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              View
            </text>
            <text
              x="580"
              y="588"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Planner
            </text>

            <ellipse
              cx="650"
              cy="650"
              rx="60"
              ry="30"
              fill="url(#plannerGradient)"
              stroke="#059669"
              stroke-width="2"
            />
            <text
              x="650"
              y="645"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Set
            </text>
            <text
              x="650"
              y="658"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Reminders
            </text>

            <ellipse
              cx="480"
              cy="700"
              rx="75"
              ry="30"
              fill="url(#plannerGradient)"
              stroke="#059669"
              stroke-width="2"
            />
            <text
              x="480"
              y="695"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Mark Session
            </text>
            <text
              x="480"
              y="708"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Complete
            </text>

            <ellipse
              cx="320"
              cy="700"
              rx="70"
              ry="30"
              fill="url(#plannerGradient)"
              stroke="#059669"
              stroke-width="2"
            />
            <text
              x="320"
              y="695"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Reschedule
            </text>
            <text
              x="320"
              y="708"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Session
            </text>

            <ellipse
              cx="220"
              cy="650"
              rx="75"
              ry="30"
              fill="url(#plannerGradient)"
              stroke="#059669"
              stroke-width="2"
            />
            <text
              x="220"
              y="645"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Get Smart
            </text>
            <text
              x="220"
              y="658"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Suggestions
            </text>

            <ellipse
              cx="420"
              cy="780"
              rx="70"
              ry="30"
              fill="url(#plannerGradient)"
              stroke="#059669"
              stroke-width="2"
            />
            <text
              x="420"
              y="775"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Receive
            </text>
            <text
              x="420"
              y="788"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Notifications
            </text>

            <ellipse
              cx="580"
              cy="780"
              rx="60"
              ry="30"
              fill="url(#plannerGradient)"
              stroke="#059669"
              stroke-width="2"
            />
            <text
              x="580"
              y="775"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Track
            </text>
            <text
              x="580"
              y="788"
              text-anchor="middle"
              font-size="11"
              font-weight="bold"
            >
              Progress
            </text>

            <!-- ASSOCIATIONS - Student to Use Cases -->
            <!-- Chatbot associations -->
            <line
              x1="105"
              y1="430"
              x2="250"
              y2="160"
              stroke="#6B7280"
              stroke-width="2"
              opacity="0.7"
            />
            <line
              x1="105"
              y1="440"
              x2="430"
              y2="160"
              stroke="#6B7280"
              stroke-width="2"
              opacity="0.7"
            />
            <line
              x1="105"
              y1="450"
              x2="550"
              y2="220"
              stroke="#6B7280"
              stroke-width="2"
              opacity="0.7"
            />
            <line
              x1="105"
              y1="460"
              x2="350"
              y2="240"
              stroke="#6B7280"
              stroke-width="2"
              opacity="0.7"
            />
            <line
              x1="105"
              y1="450"
              x2="185"
              y2="220"
              stroke="#6B7280"
              stroke-width="2"
              opacity="0.7"
            />
            <line
              x1="105"
              y1="470"
              x2="185"
              y2="320"
              stroke="#6B7280"
              stroke-width="2"
              opacity="0.7"
            />
            <line
              x1="105"
              y1="460"
              x2="320"
              y2="320"
              stroke="#6B7280"
              stroke-width="2"
              opacity="0.7"
            />
            <line
              x1="105"
              y1="450"
              x2="555"
              y2="380"
              stroke="#6B7280"
              stroke-width="2"
              opacity="0.7"
            />

            <!-- Planner associations -->
            <line
              x1="105"
              y1="470"
              x2="215"
              y2="580"
              stroke="#6B7280"
              stroke-width="2"
              opacity="0.7"
            />
            <line
              x1="105"
              y1="480"
              x2="345"
              y2="580"
              stroke="#6B7280"
              stroke-width="2"
              opacity="0.7"
            />
            <line
              x1="105"
              y1="490"
              x2="520"
              y2="580"
              stroke="#6B7280"
              stroke-width="2"
              opacity="0.7"
            />
            <line
              x1="105"
              y1="500"
              x2="590"
              y2="650"
              stroke="#6B7280"
              stroke-width="2"
              opacity="0.7"
            />
            <line
              x1="105"
              y1="510"
              x2="405"
              y2="700"
              stroke="#6B7280"
              stroke-width="2"
              opacity="0.7"
            />
            <line
              x1="105"
              y1="500"
              x2="250"
              y2="700"
              stroke="#6B7280"
              stroke-width="2"
              opacity="0.7"
            />
            <line
              x1="105"
              y1="480"
              x2="145"
              y2="650"
              stroke="#6B7280"
              stroke-width="2"
              opacity="0.7"
            />
            <line
              x1="105"
              y1="520"
              x2="350"
              y2="780"
              stroke="#6B7280"
              stroke-width="2"
              opacity="0.7"
            />
            <line
              x1="105"
              y1="530"
              x2="520"
              y2="780"
              stroke="#6B7280"
              stroke-width="2"
              opacity="0.7"
            />

            <!-- Secondary Actor Associations -->
            <!-- AI System to chatbot use cases -->
            <line
              x1="875"
              y1="280"
              x2="390"
              y2="160"
              stroke="#3B82F6"
              stroke-width="2"
              opacity="0.6"
            />
            <line
              x1="875"
              y1="290"
              x2="570"
              y2="160"
              stroke="#3B82F6"
              stroke-width="2"
              opacity="0.6"
            />
            <line
              x1="875"
              y1="300"
              x2="690"
              y2="220"
              stroke="#3B82F6"
              stroke-width="2"
              opacity="0.6"
            />
            <line
              x1="875"
              y1="310"
              x2="490"
              y2="240"
              stroke="#3B82F6"
              stroke-width="2"
              opacity="0.6"
            />
            <line
              x1="875"
              y1="320"
              x2="590"
              y2="320"
              stroke="#3B82F6"
              stroke-width="2"
              opacity="0.6"
            />
            <line
              x1="875"
              y1="330"
              x2="295"
              y2="650"
              stroke="#3B82F6"
              stroke-width="2"
              opacity="0.6"
            />

            <!-- Study Materials System -->
            <line
              x1="1175"
              y1="380"
              x2="490"
              y2="240"
              stroke="#8B5CF6"
              stroke-width="2"
              opacity="0.6"
            />

            <!-- Notification System -->
            <line
              x1="875"
              y1="680"
              x2="720"
              y2="650"
              stroke="#EF4444"
              stroke-width="2"
              opacity="0.6"
            />
            <line
              x1="875"
              y1="690"
              x2="490"
              y2="780"
              stroke="#EF4444"
              stroke-width="2"
              opacity="0.6"
            />

            <!-- INCLUDE/EXTENDS RELATIONSHIPS -->
            <!-- Include: Schedule Study Session includes Set Reminders -->
            <line
              x1="465"
              y1="610"
              x2="605"
              y2="650"
              stroke="#059669"
              stroke-width="2"
              stroke-dasharray="8,4"
              marker-end="url(#arrowhead)"
            />
            <text
              x="535"
              y="635"
              font-size="10"
              fill="#059669"
              font-weight="bold"
            >
              «include»
            </text>

            <!-- Include: Ask Follow-up includes View Chat History -->
            <line
              x1="575"
              y1="250"
              x2="305"
              y2="220"
              stroke="#6B46C1"
              stroke-width="2"
              stroke-dasharray="8,4"
              marker-end="url(#arrowhead)"
            />
            <text
              x="440"
              y="230"
              font-size="10"
              fill="#6B46C1"
              font-weight="bold"
            >
              «include»
            </text>

            <!-- Extends: Upload Files extends Ask Academic Question -->
            <line
              x1="350"
              y1="290"
              x2="350"
              y2="190"
              stroke="#DC2626"
              stroke-width="2"
              stroke-dasharray="8,4"
              marker-end="url(#arrowhead)"
            />
            <text
              x="270"
              y="240"
              font-size="10"
              fill="#DC2626"
              font-weight="bold"
            >
              «extends»
            </text>

            <!-- Extends: Get Smart Suggestions extends Create Study Goal -->
            <line
              x1="255"
              y1="620"
              x2="255"
              y2="610"
              stroke="#DC2626"
              stroke-width="2"
              stroke-dasharray="8,4"
              marker-end="url(#arrowhead)"
            />
            <text
              x="170"
              y="600"
              font-size="10"
              fill="#DC2626"
              font-weight="bold"
            >
              «extends»
            </text>

            <!-- Legend -->
            <g transform="translate(1000, 550)">
              <rect
                x="0"
                y="0"
                width="220"
                height="200"
                fill="white"
                stroke="#374151"
                stroke-width="2"
                rx="10"
              />
              <text
                x="110"
                y="20"
                text-anchor="middle"
                font-size="16"
                font-weight="bold"
                fill="#374151"
              >
                Legend
              </text>

              <line
                x1="15"
                y1="40"
                x2="50"
                y2="40"
                stroke="#6B7280"
                stroke-width="2"
              />
              <text x="60" y="45" font-size="12" fill="#374151">
                Association
              </text>

              <line
                x1="15"
                y1="60"
                x2="50"
                y2="60"
                stroke="#059669"
                stroke-width="2"
                stroke-dasharray="8,4"
              />
              <text x="60" y="65" font-size="12" fill="#059669">«include»</text>

              <line
                x1="15"
                y1="80"
                x2="50"
                y2="80"
                stroke="#DC2626"
                stroke-width="2"
                stroke-dasharray="8,4"
              />
              <text x="60" y="85" font-size="12" fill="#DC2626">«extends»</text>

              <ellipse
                cx="30"
                cy="105"
                rx="25"
                ry="12"
                fill="url(#chatbotGradient)"
                stroke="#6B46C1"
                stroke-width="1"
              />
              <text x="70" y="110" font-size="12" fill="#374151">
                Chatbot Use Case
              </text>

              <ellipse
                cx="30"
                cy="130"
                rx="25"
                ry="12"
                fill="url(#plannerGradient)"
                stroke="#059669"
                stroke-width="1"
              />
              <text x="70" y="135" font-size="12" fill="#374151">
                Planner Use Case
              </text>

              <circle
                cx="30"
                cy="155"
                r="10"
                fill="#FEF3C7"
                stroke="#F59E0B"
                stroke-width="2"
              />
              <text x="50" y="160" font-size="12" fill="#374151">Actor</text>

              <rect
                x="10"
                y="170"
                width="30"
                height="15"
                fill="none"
                stroke="#6B46C1"
                stroke-width="2"
                rx="3"
              />
              <text x="50" y="180" font-size="12" fill="#374151">
                System Boundary
              </text>
            </g>
          </svg>
        </div>

        <div class="documentation">
          <div class="doc-section">
            <h3>🤖 AI Chatbot Features</h3>
            <ul>
              <li>
                <span class="use-case-id">UC2.1:</span> Ask Academic Question -
                Student queries AI for academic help
              </li>
              <li>
                <span class="use-case-id">UC2.2:</span> Get Homework Help -
                Specific assistance with homework problems
              </li>
              <li>
                <span class="use-case-id">UC2.3:</span> Ask Follow-up Question -
                Continue conversation with context
              </li>
              <li>
                <span class="use-case-id">UC2.4:</span> Query Study Notes (RAG)
                - Ask questions about uploaded materials
              </li>
              <li>
                <span class="use-case-id">UC2.6:</span> View Chat History -
                Access previous conversations
              </li>
              <li>
                <strong>Create Conversation:</strong> Start new chat sessions
              </li>
              <li>
                <strong>Upload Files:</strong> Attach documents for AI analysis
              </li>
              <li>
                <strong>Stream AI Response:</strong> Real-time AI message
                streaming
              </li>
              <li>
                <strong>Manage Conversations:</strong> Edit, delete, organize
                chats
              </li>
            </ul>
          </div>

          <div class="doc-section">
            <h3>📅 Study Planner Features</h3>
            <ul>
              <li>
                <span class="use-case-id">UC5.1:</span> Create Study Goal - Set
                learning objectives with deadlines
              </li>
              <li>
                <span class="use-case-id">UC5.2:</span> Schedule Study Session -
                Plan specific study times
              </li>
              <li>
                <span class="use-case-id">UC5.3:</span> Set Reminders -
                Configure notification preferences
              </li>
              <li>
                <span class="use-case-id">UC5.4:</span> View Planner - Access
                calendar and agenda views
              </li>
              <li>
                <span class="use-case-id">UC5.5:</span> Mark Session Complete -
                Track session completion
              </li>
              <li>
                <span class="use-case-id">UC5.6:</span> Receive Notifications -
                Get study reminders
              </li>
              <li>
                <span class="use-case-id">UC5.7:</span> Reschedule Session -
                Modify existing sessions
              </li>
              <li>
                <span class="use-case-id">UC5.8:</span> Get Smart Suggestions -
                AI-powered scheduling recommendations
              </li>
              <li>
                <strong>Track Progress:</strong> Monitor goal achievement and
                study patterns
              </li>
            </ul>
          </div>

          <div class="doc-section actor-section">
            <h3>🎭 System Actors</h3>
            <ul>
              <li>
                <strong>Student:</strong> Primary user interacting with both
                systems
              </li>
              <li>
                <strong>AI System:</strong> Processes chat requests and provides
                intelligent responses
              </li>
              <li>
                <strong>Notification System:</strong> Handles reminders and
                alerts for study sessions
              </li>
              <li>
                <strong>Study Materials System:</strong> Provides context for
                RAG functionality in chatbot
              </li>
            </ul>
          </div>

          <div class="doc-section relationship-section">
            <h3>🔗 Key Relationships</h3>
            <ul>
              <li>
                <strong>«include»:</strong> Mandatory sub-processes that are
                always executed
              </li>
              <li>
                <strong>«extends»:</strong> Optional enhancements that may be
                triggered
              </li>
              <li>
                <strong>Association:</strong> Direct user interactions with use
                cases
              </li>
              <li>
                <strong>System Integration:</strong> Smart suggestions link
                planner with AI system
              </li>
            </ul>
          </div>

          <div class="doc-section tech-section">
            <h3>🏗️ Technical Implementation</h3>
            <ul>
              <li>
                <strong>Frontend:</strong> Flutter with Riverpod state
                management
              </li>
              <li>
                <strong>Backend:</strong> Supabase with PostgreSQL and Edge
                Functions
              </li>
              <li>
                <strong>AI Integration:</strong> Vercel AI SDK for LLM
                abstraction
              </li>
              <li>
                <strong>Real-time:</strong> Streaming responses and live
                notifications
              </li>
              <li>
                <strong>Data Storage:</strong> Supabase for conversations and
                planner data
              </li>
            </ul>
          </div>

          <div class="doc-section">
            <h3>📋 Project Context</h3>
            <ul>
              <li>
                <strong>Course:</strong> 6002CEM Mobile App Development - CW2
              </li>
              <li><strong>Team:</strong> Matthew & Thor Wen Zheng</li>
              <li>
                <strong>Focus Areas:</strong> Chatbot & Study Planner components
              </li>
              <li>
                <strong>Architecture:</strong> Clean Architecture with feature
                modules
              </li>
              <li>
                <strong>Platform:</strong> Flutter cross-platform mobile
                application
              </li>
            </ul>
          </div>
        </div>
      </div>

      <footer class="footer">
        <p>
          Athena AI Study Companion | 6002CEM CW2 | Chatbot & Study Planner Use
          Case Analysis
        </p>
      </footer>
    </div>
  </body>
</html>
```
