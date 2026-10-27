# GenAI Stack - AI-Powered Support Bot UI

An AI-powered support bot user interface built with Svelte, Vite, and Tailwind CSS. Features include:

- **Voice Input/Output** - Speak your questions and listen to responses
- **Knowledge Graph RAG** - Leverages Neo4j knowledge graphs for intelligent answers
- **Accessibility First** - Full keyboard navigation and ARIA labels
- **Modern UI** - Clean, responsive interface with smooth animations

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Svelte](https://img.shields.io/badge/-Svelte-FF3E00?logo=svelte&logoColor=white)](https://svelte.dev)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-38B2AC?logo=tailwind-css&logoColor=white)](https://tailwindcss.com)

## ✨ Features

### Voice Capabilities

- **Voice Input** - Click the "Voice" button to speak your question (uses Web Speech API)
- **Text-to-Speech** - Bot responses are automatically read aloud (configurable)
- **Cross-Browser Support** - Works in Chrome, Edge, Safari, and other modern browsers

### AI & RAG

- **RAG Mode** - Toggle between pure LLM responses and RAG-enabled answers with knowledge graph context
- **Source Citations** - Answers include citations with links to relevant Stack Overflow questions
- **Multiple Models** - Support for various LLMs via the API backend

### Accessibility

- **Keyboard Navigation** - Full keyboard support with visible focus states
- **Screen Reader Compatible** - Proper ARIA labels and roles throughout
- **High Contrast** - Accessible color palette with proper contrast ratios

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ or higher
- npm, yarn, or pnpm

### Installation

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

The application will be available at `http://localhost:5173`.

## 🛠️ Configuration

The frontend connects to the API backend at `http://localhost:8504`. To change this, update the `API_ENDPOINT` in `src/lib/chat.store.js`.

## 🎮 Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl + K` or `Cmd + K` | Focus the input field |
| `Ctrl + Enter` or `Cmd + Enter` | Send the message |
| `Escape` | Close modals |

## 🎤 Voice Features

### Using Voice Input

1. Click the microphone ("Voice") button in the input area
2. Speak your question clearly
3. The transcribed text will appear in the input field
4. Click "Send" or press `Ctrl + Enter`

### Voice Settings

The application automatically selects the first available English voice. To use a different voice:

```javascript
// In App.svelte, modify the voice selection logic
selectedVoice = voices.find(v => v.name.includes('Google US English'));
```

### Browser Support

Voice features work in browsers that support the Web Speech API:
- ✅ Chrome/Edge (full support)
- ✅ Safari (full support)
- ✅ Firefox (requires manual enablement)
- ⚠️ Mobile browsers (limited support)

## 📁 Project Structure

```
front-end/
├── src/
│   ├── lib/
│   │   ├── chat.store.js      # Chat state management
│   │   ├── generation.store.js # Ticket generation store
│   │   ├── Modal.svelte       # Modal component
│   │   ├── MdLink.svelte      # Markdown link renderer
│   │   └── External.svelte    # External link icon
│   ├── assets/
│   │   └── images/
│   │       ├── bot.jpeg       # Bot avatar
│   │       └── me.jpeg        # User avatar
│   ├── App.svelte             # Main application component
│   ├── main.js                # Application entry point
│   └── app.css                # Global styles + Tailwind directives
├── public/                    # Static assets
├── index.html                 # HTML template with SEO meta tags
├── package.json
├── svelte.config.js
├── tailwind.config.js
└── vite.config.js
```

## 🎨 Customization

### Changing the Theme

Modify `tailwind.config.js` to change colors, fonts, and other design tokens:

```javascript
theme: {
  extend: {
    colors: {
      primary: '#6366f1', // Change this
    },
  },
}
```

### Adding New Features

1. Add components to `src/lib/`
2. Import and use them in `App.svelte`
3. Update state management in `.store.js` files as needed

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guidelines](../CONTRIBUTING.md) first.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📚 Learn More

- [GenAI Stack Documentation](https://genai-stack.dev)
- [Neo4j Knowledge Graph RAG](https://neo4j.com/developer/graph-data-science/)
- [Svelte Documentation](https://svelte.dev/docs)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Svelte](https://svelte.dev) and [Vite](https://vitejs.dev)
- Styling with [Tailwind CSS](https://tailwindcss.com)
- Powered by [Neo4j](https://neo4j.com) knowledge graphs
- LLM integration via [LangChain](https://langchain.com)

---

**Note**: Voice features use the Web Speech API which is still experimental in some browsers. Features may vary across different browser versions.