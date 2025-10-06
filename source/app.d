import std.experimental.logger;
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
    output.serveFile("public");
}
