import std;

import diet.html;
import serverino;
import tailwind;

mixin ServerinoMain;

@onServerInit ServerinoConfig configure()
{
    Tailwind tailwind = new Tailwind;

	tailwind.input = "assets/app.css";
	tailwind.output = "public/styles.css";

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
void index(Request req, Output output) {
	auto page = appender!string;
	bool isHTMX = req.header.read("hx-request") == "true" ? true : false;

	if (isHTMX)
	    page.compileHTMLDietFile!("index_dynamic.dt");
	else
	    page.compileHTMLDietFile!("index.dt");
	output ~= page.data;
}

@endpoint @route!"/login-form"
void loginForm(Request req, Output output) {
	auto page = appender!string;
	page.compileHTMLDietFile!("login.dt");
	output ~= page.data;
}

@endpoint @route!"/show-form"
void showForm(Request req, Output output) {
	auto page = appender!string;
	page.compileHTMLDietFile!("form.dt");
	output ~= page.data;
}

@endpoint @priority(-1)
void other(Request req, Output output) {
	output.status = 404;
	output.addHeader("Content-Type", "text/plain");
	output.write("Page not found!");
}

@endpoint @route!"/submit-talk"
void submitTalk(Request r, Output o)
{
    auto name = r.post.read("name");
    auto theme = r.post.read("theme");
    auto experience = r.post.read("experience");
    auto durationStr = r.post.read("duration");

    // Basic validation
    if (name.length == 0 || theme.length == 0 || experience.length == 0 || durationStr.length == 0) {
        // Return an error fragment or message
        o.status = 400;
        o ~= "<div class=\"text-red-600\">All fields are required.</div>";
        return;
    }

    int duration;
    try {
        duration = to!int(durationStr);
    } catch (ConvException) {
        o.status = 400;
        o ~= "<div class=\"text-red-600\">Duration must be a number.</div>";
        return;
    }

    info("Received talk proposal: ", name, ", theme: ", theme, ", experience: ", experience, ", duration: ", duration);

    auto page = appender!string;
	page.compileHTMLDietFile!("form_finished.dt");
	o ~= page.data;
}

@endpoint @route!(r => r.path.endsWith(".css"))
void css(Request r, Output o) {
	auto pathOnDisk = "." ~ r.path;
	if (exists(pathOnDisk)) {
	    o.serveFile(pathOnDisk);
	}
	else {
	    warning("Non existing path to serve: ", r.path);
	    return;
	}
}
