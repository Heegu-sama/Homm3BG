# Using AI for translations

This guide explains how to use AI models to help translate the rule book while maintaining proper formatting and consistency.
While AI does not translate perfectly, it can help you achieve the desired result a lot faster.

## Getting Started

### **Choose an AI Model**

[Claude Sonnet](https://claude.ai) and [GPT-4](https://openai.com/product/gpt-4) have been tested and proven to work well.
Free tier models also work, but they give noticeably worse results.

### **Set up your prompt**

Start a new conversation with the AI.
Copy the entire prompt in a chosen language in this directory.
For instance, if you're translating to Polsh, copy `pl.txt`.
If the file for your language isn't tranlsated yet, you should do that first.
Translate the prompt for your language in `translations/prompt.txt/<your_language>.po`, run `po4a`, and commit the result.
Then, copy the resulting file `tools/translation-ai-prompts/<your_language>.txt`.
**Send this as your first message to the AI to establish the context.**

### **Sending translation requests**

If you have the following `msgid` to translate:

```po
msgid ""
"The continent of Antagarich is at war as several different Factions, led by "
"their Heroes, battle for supremacy. Choose your Faction and Hero and banish "
"your unruly enemies from these lands!"
```

Start your prompt with this:
~~~
```po
~~~
Then, press Shift+Enter and paste the entire `msgid`.
The AI will reply with translated and properly formatted `msgstr`.

### Best Practices

1. Send one section or paragraph at a time.

2. If you notice inconsistencies, remind the AI about specific game terms.

3. If you have specific requirements for a section, state them clearly.
Example: "Make this section shorter, as its taking too much space".

4. If you need corrections, show the AI both the original and its previous translation, and then state what you need.
Example: "Fix the LaTeX formatting in this line while keeping the translation".

5. If the AI forgets formatting rules, uses inconsistent terminology or changes LaTeX commands, simply remind it of the specific rules it should follow. You can quote the relevant section from the original prompt.
Sometimes it works best to start a new chat.

## Remember: The AI is a tool to assist with translation, but final review and verification should always be done by a human familiar with both the language and the game rules.


### Managing prompts

Maintaining a good prompt is a process, so changes to the `prompt.txt` template are welcome.
One can always add more game terms, and state LaTeX and po formatting rules more clearly.
