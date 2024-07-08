/*
c 2023-10-22
m 2023-11-21
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

string Round(bool b) {
    return (b ? GREEN : RED) + b;
}

string Round(int num) {
    return (num == 0 ? WHITE : num < 0 ? RED : GREEN) + Math::Abs(num);
}

// overload above converts uints to ints, which we don't want
string RoUnd(uint num) {
    return (num == 0 ? WHITE : GREEN) + num;
}

string Round(float num, uint precision = 3) {
    return (num == 0 ? WHITE : num < 0 ? RED : GREEN) + Text::Format("%." + precision + "f", Math::Abs(num)) + "\\$G";
}

string Round(vec3 vec, uint precision = 3) {
    return Round(vec.x, precision) + " , " + Round(vec.y, precision) + " , " + Round(vec.z, precision);
}

string Round(iso4 iso, uint precision = 3) {
    string ret;

    ret += Round(iso.tx, precision) + " , " + Round(iso.ty, precision) + " , " + Round(iso.tz, precision) + "\n";
    ret += Round(iso.xx, precision) + " , " + Round(iso.xy, precision) + " , " + Round(iso.xz, precision) + "\n";
    ret += Round(iso.yx, precision) + " , " + Round(iso.yy, precision) + " , " + Round(iso.yz, precision) + "\n";
    ret += Round(iso.zx, precision) + " , " + Round(iso.zy, precision) + " , " + Round(iso.zz, precision);

    return ret;
}

class String4 {
    string offset;
    string type;
    string name;
    string value;

    String4() { }
    String4(const string &in o, const string &in t, const string &in n, const string &in v) {
        offset = o;
        type   = t;
        name   = n;
        value  = v;
    }
    String4(uint o, const string &in t, const string &in n, const string &in v) {
        offset = tostring(o);
        type   = t;
        name   = n;
        value  = v;
    }
}

enum DataType {
    Int8,
    Uint8,
    Int16,
    Uint16,
    Int32,
    Uint32,
    Int64,
    Uint64,
    Float,
    Vec3
}
