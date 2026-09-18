import "./style.css";

const app = document.querySelector<HTMLElement>("#app");
if (!app) throw new Error("#app element not found");

const heading = document.createElement("h1");
heading.className = "text-3xl font-bold";
heading.textContent = "{{NAME}}";
app.append(heading);
