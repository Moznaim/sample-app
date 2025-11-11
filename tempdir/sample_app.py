from flask import Flask, request, render_template

sample = Flask(__name__)

@sample.route("/")
def main():
    return render_template("index.html")

if __name__ == "__main__":
    # avoid spawning threads/reloader (your env is thread-limited)
    sample.run(host="0.0.0.0", port=5050, debug=False, threaded=False, use_reloader=False)

