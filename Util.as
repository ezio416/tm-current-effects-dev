/*
c 2023-10-22
m 2023-10-22
*/

const string BLUE   = "\\$09D";
const string CYAN   = "\\$2FF";
const string GRAY   = "\\$888";
const string GREEN  = "\\$0D2";
const string ORANGE = "\\$F90";
const string PURPLE = "\\$F0F";
const string RED    = "\\$F00";
const string WHITE  = "\\$FFF";
const string YELLOW = "\\$FF0";

string Round(float num, uint precision = 6) {
    return (num == 0 ? WHITE : num < 0 ? RED : GREEN) + Text::Format("%." + precision + "f", Math::Abs(num)) + "\\$G";
}

string RoundVec3(vec3 vec, uint precision = 6) {
    return Round(vec.x, precision) + " , " + Round(vec.y, precision) + " , " + Round(vec.z, precision);
}

class String4 {
    string offset;
    string type;
    string name;
    string value;

    String4() { }
    String4(const string &in o, const string &in t, const string &in n, const string &in v) {
        offset = o;
        type = t;
        name = n;
        value = v;
    }
    String4(uint o, const string &in t, const string &in n, const string &in v) {
        offset = "" + o;
        type = t;
        name = n;
        value = v;
    }
}