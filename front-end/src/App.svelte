<script>
    import { tick } from "svelte";
    import SvelteMarkdown from "svelte-markdown";
    import botImage from "./assets/images/bot.jpeg";
    import meImage from "./assets/images/me.jpeg";
    import MdLink from "./lib/MdLink.svelte";
    import External from "./lib/External.svelte";
    import { chatStates, chatStore } from "./lib/chat.store.js";
    import Modal from "./lib/Modal.svelte";
    import { generationStore } from "./lib/generation.store";

    let ragMode = false;
    let question = "How can I calculate age from date of birth in Cypher?";
    let shouldAutoScroll = true;
    let input;
    let senderImages = { bot: botImage, me: meImage };
    let generationModalOpen = false;
    let voiceActive = false;
    let recognition = null;
    let synth = window.speechSynthesis;
    let voices = [];
    let selectedVoice = null;

    // Load available voices
    function loadVoices() {
        voices = synth.getVoices();
        if (voices.length > 0) {
            selectedVoice = voices.find(v => v.lang.includes('en')) || voices[0];
        }
    }

    if (typeof window !== 'undefined') {
        loadVoices();
        if ('speechSynthesis' in window) {
            window.speechSynthesis.onvoiceschanged = loadVoices;
        }
    }

    // Voice recognition setup
    function setupVoiceRecognition() {
        const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
        if (!SpeechRecognition) {
            console.warn('Speech recognition not supported');
            return null;
        }

        const recognition = new SpeechRecognition();
        recognition.continuous = false;
        recognition.lang = 'en-US';
        recognition.interimResults = false;

        recognition.onstart = () => {
            voiceActive = true;
        };

        recognition.onend = () => {
            voiceActive = false;
        };

        recognition.onerror = (event) => {
            console.error('Voice recognition error:', event.error);
            voiceActive = false;
        };

        recognition.onresult = (event) => {
            const transcript = event.results[0][0].transcript;
            question = transcript;
        };

        return recognition;
    }

    // Toggle voice recognition
    function toggleVoice() {
        if (!recognition) {
            recognition = setupVoiceRecognition();
        }
        
        if (recognition) {
            if (voiceActive) {
                recognition.stop();
            } else {
                recognition.start();
            }
        }
    }

    // Text-to-speech
    function speakResponse(text) {
        if (!synth || !text) return;

        // Cancel any ongoing speech
        synth.cancel();

        const utterance = new SpeechSynthesisUtterance(text);
        utterance.voice = selectedVoice;
        utterance.rate = 1.0;
        utterance.pitch = 1.0;

        synth.speak(utterance);
    }

    function send() {
        chatStore.send(question, ragMode);
        question = "";
    }

    function scrollToBottom(node, _) {
        const scroll = () => node.scrollTo({ top: node.scrollHeight });
        scroll();
        return { update: () => shouldAutoScroll && scroll() };
    }

    function scrolling(e) {
        shouldAutoScroll = e.target.scrollTop + e.target.clientHeight > e.target.scrollHeight - 55;
    }

    function generateTicket(text) {
        generationStore.generate(text);
        generationModalOpen = true;
    }

    // Keyboard shortcuts
    function handleKeyDown(e) {
        // Ctrl+K or Cmd+K to focus input
        if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
            e.preventDefault();
            if (input) input.focus();
        }
        
        // Ctrl+Enter or Cmd+Enter to send
        if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
            e.preventDefault();
            if (input && input.value.trim()) {
                send();
            }
        }
        
        // Escape to close modal
        if (e.key === 'Escape' && generationModalOpen) {
            generationModalOpen = false;
        }
    }

    // Listen for chat store updates and enable TTS
    let unsubscribe = () => {};
    $: {
        if ($chatStore.state === chatStates.IDLE && $chatStore.data.length > 0) {
            const lastMessage = $chatStore.data[$chatStore.data.length - 1];
            if (lastMessage.from === 'bot' && lastMessage.text) {
                // Small delay to ensure message is fully rendered
                setTimeout(() => {
                    if (lastMessage.text && !lastMessage.speechPlayed) {
                        speakResponse(lastMessage.text);
                        // Mark as spoken
                        const updatedData = [...$chatStore.data];
                        updatedData[updatedData.length - 1].speechPlayed = true;
                    }
                }, 500);
            }
        }
    }

    $: $chatStore.state === chatStates.IDLE && input && focus(input);
    async function focus(node) {
        await tick();
        node.focus();
    }

    ondestroy(() => {
        unsubscribe();
        if (recognition) recognition.stop();
        synth.cancel();
    });
</script>

<main 
    class="h-full text-sm bg-gradient-to-t from-indigo-100 bg-fixed overflow-hidden" 
    tabindex="0"
    on:keydown={handleKeyDown}
>
    <div on:scroll={scrolling} class="flex h-full flex-col py-12 overflow-y-auto" use:scrollToBottom={$chatStore} role="main" aria-label="Chat interface">
        <div class="w-4/5 mx-auto flex flex-col mb-32">
            {#each $chatStore.data as message (message.id)}
                <div
                    class="max-w-[80%] min-w-[40%] rounded-lg p-4 mb-4 overflow-x-auto bg-white border border-indigo-200 shadow-sm transition-all duration-200 hover:shadow-md"
                    class:self-end={message.from === "me"}
                    class:text-right={message.from === "me"}
                    aria-label="{message.from === 'me' ? 'Your message' : 'Bot response'}"
                >
                    <div class="flex flex-row gap-2">
                        {#if message.from === "me"}
                            <button
                                aria-label="Generate a new internal ticket from this question"
                                title="Generate a new internal ticket from this question"
                                on:click={() => generateTicket(message.text)}
                                class="w-6 h-6 flex flex-col justify-center items-center border rounded border-indigo-200 hover:bg-indigo-50 transition-colors"
                                ><External --color="#ccc" --hover-color="#999" /></button
                            >
                        {/if}
                        <div
                            class:ml-auto={message.from === "me"}
                            class="relative w-12 h-12 border border-indigo-200 rounded flex justify-center items-center overflow-hidden"
                        >
                            <img 
                                src={senderImages[message.from]} 
                                alt={message.from === "me" ? "User avatar" : "Bot avatar"} 
                                class="rounded-sm" 
                                loading="lazy"
                            />
                        </div>
                        {#if message.from === "bot"}
                            <div class="text-sm">
                                <div>Model: {message.model ? message.model : ""}</div>
                                <div>RAG: {message.rag ? "Enabled" : "Disabled"}</div>
                            </div>
                        {/if}
                    </div>
                    <div class="mt-4">
                        <SvelteMarkdown source={message.text} renderers={{ link: MdLink }} />
                    </div>
                </div>
            {/each}
            
            {#if $chatStore.data.length === 0}
                <div class="w-4/5 mx-auto text-center py-12 text-gray-500">
                    <h2 class="text-2xl font-semibold mb-4">Welcome to GenAI Stack Support Bot</h2>
                    <p class="mb-4">Ask me anything about programming, Cypher, or our knowledge graph.</p>
                    <p class="text-sm">Press <kbd class="px-2 py-1 bg-gray-100 rounded">Ctrl</kbd> + <kbd class="px-2 py-1 bg-gray-100 rounded">K</kbd> to focus the input</p>
                </div>
            {/if}
        </div>
        
        <div class="text-sm w-full fixed bottom-16" role="complementary" aria-label="Input area">
            <div class="shadow-lg bg-indigo-50 rounded-lg w-4/5 xl:w-2/3 2xl:w-1/2 mx-auto p-4">
                <div class="rounded-t-lg px-4 py-3 bg-white border-b border-indigo-200">
                    <div class="flex items-center justify-between">
                        <div>
                            <div class="font-semibold">RAG mode</div>
                            <div class="text-xs text-gray-600">
                                {#if ragMode}
                                    <span class="text-green-600 font-medium">Enabled</span> - Using vector + knowledge graph context
                                {:else}
                                    <span class="text-gray-500">Disabled</span> - Pure LLM response
                                {/if}
                            </div>
                        </div>
                        
                        <!-- Voice Toggle Button -->
                        <button
                            on:click={toggleVoice}
                            class={`
                                flex items-center gap-2 px-3 py-1.5 rounded-md text-sm font-medium transition-all duration-200
                                {#if voiceActive}
                                    bg-red-500 text-white hover:bg-red-600
                                {:else}
                                    bg-indigo-100 text-indigo-700 hover:bg-indigo-200
                                {/if}
                            `}
                            aria-pressed={voiceActive}
                            aria-label={voiceActive ? "Stop voice input" : "Start voice input"}
                            title="Click to speak your question"
                        >
                            <svg 
                                class="w-4 h-4" 
                                fill="none" 
                                stroke="currentColor" 
                                viewBox="0 0 24 24" 
                                xmlns="http://www.w3.org/2000/svg"
                            >
                                <path 
                                    stroke-linecap="round" 
                                    stroke-linejoin="round" 
                                    stroke-width="2" 
                                    d={voiceActive ? "M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" : "M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z"}
                                />
                            </svg>
                            {voiceActive ? "Listening..." : "Voice"}
                        </button>
                    </div>
                    
                    <div class="mt-2 flex items-center gap-2">
                        <label class="inline-flex items-center cursor-pointer">
                            <input 
                                type="radio" 
                                bind:group={ragMode} 
                                value={false} 
                                class="w-4 h-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
                            />
                            <span class="ml-2 text-sm">Disabled</span>
                        </label>
                        <label class="inline-flex items-center cursor-pointer">
                            <input 
                                type="radio" 
                                bind:group={ragMode} 
                                value={true} 
                                class="w-4 h-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
                            />
                            <span class="ml-2 text-sm">Enabled</span>
                        </label>
                    </div>
                </div>
                
                <form 
                    class="rounded-md w-full bg-white p-3 m-0 flex gap-2" 
                    on:submit|preventDefault={send}
                    role="search"
                    aria-label="Ask a question"
                >
                    <input
                        placeholder="What coding related question can I help you with? Press Ctrl+K to focus..."
                        disabled={$chatStore.state === chatStates.RECEIVING}
                        class="text-lg w-full bg-gray-50 focus:bg-white border-2 border-gray-200 focus:border-indigo-500 rounded-lg px-4 py-2 transition-colors outline-none"
                        bind:value={question}
                        bind:this={input}
                        type="text"
                        autocomplete="off"
                        aria-label="Enter your question"
                        aria-disabled={$chatStore.state === chatStates.RECEIVING}
                    />
                    
                    <button
                        type="submit"
                        disabled={$chatStore.state === chatStates.RECEIVING || !question.trim()}
                        class="
                            px-6 py-2 bg-indigo-600 text-white rounded-lg font-medium
                            hover:bg-indigo-700 focus:ring-4 focus:ring-indigo-300
                            disabled:opacity-50 disabled:cursor-not-allowed
                            transition-all duration-200 flex items-center gap-2
                        "
                        aria-label="Send message"
                    >
                        <svg 
                            class="w-5 h-5" 
                            fill="none" 
                            stroke="currentColor" 
                            viewBox="0 0 24 24" 
                            xmlns="http://www.w3.org/2000/svg"
                        >
                            <path 
                                stroke-linecap="round" 
                                stroke-linejoin="round" 
                                stroke-width="2" 
                                d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"
                            />
                        </svg>
                        <span class="hidden sm:inline">Send</span>
                        <span class="sr-only sm:not-sr-only sm:whitespace-nowrap">Send</span>
                    </button>
                </form>
                
                <div class="px-4 py-2 text-xs text-gray-500 flex justify-between">
                    <span>Press <kbd class="px-1.5 py-0.5 bg-gray-200 rounded">Ctrl</kbd> + <kbd class="px-1.5 py-0.5 bg-gray-200 rounded">Enter</kbd> to send</span>
                    <span>Use <kbd class="px-1.5 py-0.5 bg-gray-200 rounded">Voice</kbd> to speak</span>
                </div>
            </div>
        </div>
    </div>
</main>

{#if generationModalOpen}
    <Modal 
        title="Ticket Generated" 
        text="Your support ticket has been generated based on the current conversation. The ticket includes a title and detailed question formatted in the style of high-quality Stack Overflow questions." 
        on:close={() => (generationModalOpen = false)} 
    />
{/if}

<style>
    :global(pre) {
        @apply bg-gray-100 rounded-lg p-4 border border-indigo-200 overflow-x-auto;
    }
    :global(code) {
        @apply text-indigo-600 font-mono text-sm;
    }
    :global(pre code) {
        @apply text-gray-800;
    }
    
    /* Custom scrollbar */
    ::-webkit-scrollbar {
        width: 8px;
        height: 8px;
    }
    ::-webkit-scrollbar-track {
        background: #f1f1f1;
        border-radius: 4px;
    }
    ::-webkit-scrollbar-thumb {
        background: #cbd5e1;
        border-radius: 4px;
    }
    ::-webkit-scrollbar-thumb:hover {
        background: #94a3b8;
    }
</style>