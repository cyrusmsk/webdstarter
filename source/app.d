import std.experimental.logger;
import std.algorithm;
import std.datetime: seconds;

import diet.html;
import serverino;
import tailwind;

mixin ServerinoMain;

@onServerInit ServerinoConfig configure()
{
    Tailwind tailwind = new Tailwind;

	tailwind.input = "assets/app.css";
	tailwind.output = "public/styles/app.css";

	try {
		tailwind.run();
	} catch (TailwindException e) {
		info("Tailwind watch can't be started. %s", e.message);
	}

    return ServerinoConfig
    .create()
    .setHttpTimeout(15.seconds)
    .enableKeepAlive(180.seconds)
    .addListener("0.0.0.0", 8080);
}

@endpoint @route!"/"
void hello(Request req, Output output) {
    import std.array : appender;
	auto page = appender!string;	// Page will be written to this

	// Compile the page
	page.compileHTMLDietFile!("index.dt");

	// Write the page to the output
	output ~= page.data;
}

@endpoint
void other(Request req, Output output) {
    // Set the status code to 404
	output.status = 404;
	output.addHeader("Content-Type", "text/plain");

	// Write a simple message
	output.write("Page not found!");
}

@endpoint @route!(r => r.path.endsWith(".css"))
void css(Request r, Output o) { o.serveFile("public/styles/app.css"); }
