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
    // Parse form data
    auto data = r.form;  // or req.form or req.getPost(); adjust as per your Request API

    writeln(data);

    // string name = data.get("name", "");
    // string theme = data.get("theme", "");
    // string experience = data.get("experience", "");
    // string durationStr = data.get("duration", "");

    // // Basic validation
    // if (name.length == 0 || theme.length == 0 || experience.length == 0 || durationStr.length == 0) {
    //     // Return an error fragment or message
    //     o.status = 400;
    //     o ~= "<div class=\"text-red-600\">All fields are required.</div>";
    //     return;
    // }

    // int duration;
    // try {
    //     duration = to!int(durationStr);
    // } catch (ConvException) {
    //     o.status = 400;
    //     o ~= "<div class=\"text-red-600\">Duration must be a number.</div>";
    //     return;
    // }

    // // Process & save the submitted data
    // // e.g., store in DB, send email, etc.
    // writeln("Received talk proposal: ", name, ", theme: ", theme, ", experience: ", experience, ", duration: ", duration);

    // // You can return either a fragment to replace the form area,
    // // or redirect to a “thank you” page, or display a success message.
    // // For example, replace the main-content area with a thank-you message:

    // o ~= q{
    //     <div class="max-w-lg mx-auto bg-white shadow-md rounded px-6 py-8">
    //       <h2 class="text-2xl font-semibold mb-4">Thank You!</h2>
    //       <p>Your talk proposal has been submitted successfully.</p>
    //     </div>
    // };
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
