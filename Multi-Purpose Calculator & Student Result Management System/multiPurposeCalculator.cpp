#include <iostream>
#include<string>
#include<ctime>
#include<fstream>
#include<queue>
#include<thread>
#include<vector>
#pragma warning(disable:4996)
#define pi "3.14"
using namespace std;
//使用文件输入
ifstream fileInputCalc("D:/fileInputCalc.txt");
//numString类
class numString {
public:
    numString(string x = "0");
    numString operator +(numString p);
    numString operator -(numString p);
    numString operator *(numString p);
    numString operator /(numString p);
    string* stringSplit(string& p1, string& p2, bool swapStr);
    int findDotPos(string& p1, string& p2);
//数字、数字长度
    string num;
    int length;
};
//numString构造函数
numString::numString(string x) {
    num = x;
    length = x.length();
}
//将p1和p2的数字string分为整数和浮点数部分，可根据长度进行交换（swapStr选择）
string* numString::stringSplit(string& p1, string& p2, bool swapStr) {
    string* temp = new string[4];
    string::iterator itr;
    bool dot1 = false, dot2 = false;
    itr = p1.begin();
    //检测是否有小数点
    while (itr != p1.end()) {
        if (*itr == '.') {
            dot1 = true;
            break;
        }
        itr++;
    }
    itr = p2.begin();
    while (itr != p2.end()) {
        if (*itr == '.') {
            dot2 = true;
            break;
        }
        itr++;
    }
    if (dot1) {
        itr = p1.begin();
        while (*itr != '.') {
            temp[0].push_back(*itr);
            itr++;
        }
        itr++;
        while (itr != p1.end()) {
            temp[2].push_back(*itr);
            itr++;
        }
    }
    else {
        itr = p1.begin();
        while (itr != p1.end()) {
            temp[0].push_back(*itr);
            itr++;
        }
        temp[2] = "0";
    }
    if (dot2) {
        itr = p2.begin();
        while (*itr != '.') {
            temp[1].push_back(*itr);
            itr++;
        }
        itr++;
        while (itr != p2.end()) {
            temp[3].push_back(*itr);
            itr++;
        }
    }
    else {
        itr = p2.begin();
        while (itr != p2.end()) {
            temp[1].push_back(*itr);
            itr++;
        }
        temp[3] = "0";
    }
    //消除所有整数前置0和浮点数后置0
    int zerocount = 0;
    reverse(temp[2].begin(), temp[2].end());
    reverse(temp[3].begin(), temp[3].end());
    for (int i = 0; i < 4; i++) {
        zerocount = 0;
        for (itr = temp[i].begin(); itr != temp[i].end(); itr++) {
            if (*itr != '0')
                break;
            zerocount++;
        }
        temp[i].erase(0, zerocount);
    }
    reverse(temp[2].begin(), temp[2].end());
    reverse(temp[3].begin(), temp[3].end());

    if (swapStr) {
        if (temp[0].length() < temp[1].length())
            temp[0].swap(temp[1]);
        if (temp[2].length() < temp[3].length())
            temp[2].swap(temp[3]);
    }    
    return temp;
}
//计算p1和p2的小数点移至末尾所需的步数，并返回它们的和
int numString::findDotPos(string& p1, string& p2) {
    int* dotPos = new int[2];
    dotPos[0] = 0;
    dotPos[1] = 0;
    for (int i = 0; i <= int(p1.length()) - 1; i++) {
        if (p1[i] == '.') {
            dotPos[0] = p1.length() - 1 - i;
            break;
        }
    }
    for (int i = 0; i <= int(p2.length()) - 1; i++) {
        if (p2[i] == '.') {
            dotPos[1] = p2.length() - 1 - i;
            break;
        }
    }
    return dotPos[0] + dotPos[1];
}
//两个numString求和：分为整数求和与浮点数求和两个部分，并整合起来
numString numString::operator+(numString p) {
    int nextDigit = 0;
    bool negative = false;
    char tempChar;
    string* splitedString;
    string finalInt, finalFloat, finalnum;
    //str1（this的复制）和str2(p的复制）
    numString str1(*this);   
    //若数字为负号，将其对应的复制品的num属性的负号消除
    //若this->num为负，使用减法进行操作
    if (this->num[0] == '-' && p.num[0] != '-') {
        str1.num.erase(str1.num.begin());
        return p - str1;
    }
    //若p.num为负，使用减法进行操作
    if (this->num[0] != '-' && p.num[0] == '-') {
        p.num.erase(p.num.begin());
        return str1 - p;
    }
    //若两个数字皆为负，标记为negative
    if (this->num[0] == '-' && p.num[0] == '-') {
        str1.num.erase(str1.num.begin());
        p.num.erase(p.num.begin());
        negative = 1;
    }
    splitedString = stringSplit(str1.num, p.num, 1);
    for (int i = 0; i < 4; i++) {
        if (splitedString[i].empty())
            splitedString[i] = "0";
    }
    int integerDiff = splitedString[0].length() - splitedString[1].length();
    int floatDiff = splitedString[2].length() - splitedString[3].length();
    //浮点数加法
    nextDigit = 0;
    for (int i = splitedString[2].length() - 1; i >= int(splitedString[2].length()) - floatDiff; i--) {
        int temp = int(splitedString[2][i] - '0');
        tempChar = '0' + temp;
        finalFloat.push_back(tempChar);
    }
    for (int i = splitedString[2].length() - floatDiff - 1; i >= 0; i--) {
        int temp = int(splitedString[2][i] - '0') + int(splitedString[3][i] - '0') + nextDigit;
        nextDigit = temp / 10;
        tempChar = '0' + temp % 10;
        finalFloat.push_back(tempChar);
    }
    reverse(finalFloat.begin(), finalFloat.end());
    //整数加法
    for (int i = splitedString[1].length() - 1; i >= 0; i--) {
        int temp = int(splitedString[0][i + integerDiff] - '0') + int(splitedString[1][i] - '0') + nextDigit;
        nextDigit = temp / 10;
        tempChar = '0' + temp % 10;
        finalInt.push_back(tempChar);
    }
    for (int i = integerDiff - 1; i >= 0; i--) {
        int temp = int(splitedString[0][i] - '0') + nextDigit;
        nextDigit = temp / 10;
        tempChar = '0' + temp % 10;
        finalInt.push_back(tempChar);
    }
    //进位（加完后剩余的）
    if (nextDigit) {
        tempChar = '0' + nextDigit;
        finalInt.push_back(tempChar);
    }
    if (negative)
        finalnum += '-';
    reverse(finalInt.begin(), finalInt.end());
    finalnum.append(finalInt);
    finalnum += '.';
    finalnum.append(finalFloat);
    delete[]splitedString;
    return numString(finalnum);
}
//两个numString相减
numString numString::operator-(numString p) {
    int temp, borrow = 0;
    bool negative = 0;
    char tempChar;
    numString str1(*this);
    //若两个数字为负，将负号消除，并再次使用减法
    if (this->num[0] == '-' && p.num[0] == '-') {
        p.num.erase(p.num.begin());
        str1.num.erase(str1.num.begin());
        return p - str1;
    }
    //若前一个数字为负，将负号消除，并使用加法计算，最后将负号加入最终结果
    if (this->num[0] == '-' && p.num[0] != '-') {
        str1.num.erase(str1.num.begin());
        numString temp = p + str1;
        temp.num.insert(0, "-");
        return temp;
    }
    //若后一个数字为负，将负号消除，使用加法计算
    if (this->num[0] != '-' && p.num[0] == '-') {
        p.num.erase(p.num.begin());
        return str1 + p;
    }
    string* splitedString;
    string finalInt, finalFloat, finalnum;
    splitedString = stringSplit(str1.num, p.num, 0);
    for (int i = 0; i < 4; i++) {
        if (splitedString[i].empty())
            splitedString[i] = "0";
    }
    int integerDiff = splitedString[0].length() - splitedString[1].length();
    int floatDiff = splitedString[2].length() - splitedString[3].length();
    borrow = 0;
    //使两个浮点数的长度一致
    if (floatDiff < 0) {
        for (int i = 0; i < -1 * floatDiff; i++) {
            splitedString[2] += '0';
        }
    }
    if (floatDiff > 0) {
        for (int i = 0; i < floatDiff; i++) {
            splitedString[3] += '0';
        }
    }
    //处理整数情况（检测前号码还是后号码较大，再进行置换），最后将长度设成一致
    if (integerDiff < 0) {
        reverse(splitedString[0].begin(), splitedString[0].end());
        for (int i = 0; i < -1 * integerDiff; i++) {
            splitedString[0] += '0';
        }
        reverse(splitedString[0].begin(), splitedString[0].end());
        splitedString[0].swap(splitedString[1]);
        splitedString[2].swap(splitedString[3]);
        negative = 1;
    }
    else if (integerDiff > 0) {
        reverse(splitedString[1].begin(), splitedString[1].end());
        for (int i = 0; i < integerDiff; i++) {
            splitedString[1] += '0';
        }
        reverse(splitedString[1].begin(), splitedString[1].end());
    }
    else {
        if (splitedString[0].compare(splitedString[1]) == 0) {
            if (splitedString[2].compare(splitedString[3]) == 0)
                return numString();
            else {
                for (int i = 0; i <= int(splitedString[2].length()) - 1; i++) {
                    if (int(splitedString[3][i] - '0') > int(splitedString[2][i] - '0')) {
                        splitedString[2].swap(splitedString[3]);
                        negative = 1;
                        break;
                    }
                }

            }
        }
        else {
            for (int i = 0; i <= int(splitedString[1].length()) - 1; i++) {
                if (int(splitedString[1][i] - '0') > int(splitedString[0][i] - '0')) {
                    splitedString[1].swap(splitedString[0]);
                    splitedString[2].swap(splitedString[3]);
                    negative = 1;
                    break;
                }
            }
        }
    }
    //浮点数相减
    for (int i = splitedString[2].length() - 1; i >= 0; i--) {
        if (int(splitedString[2][i] - '0') - borrow >= int(splitedString[3][i] - '0')) {
            temp = int(splitedString[2][i] - '0') - int(splitedString[3][i] - '0') - borrow;
            borrow = 0;
        }
        else {
            temp = int(splitedString[2][i] - '0') + 10 - int(splitedString[3][i] - '0') - borrow;
            borrow = 1;
        }

        tempChar = '0' + temp;
        finalFloat.push_back(tempChar);
    }
    reverse(finalFloat.begin(), finalFloat.end());
    //整数相减

    for (int i = splitedString[1].length() - 1; i >= 0; i--) {
        if (int(splitedString[0][i] - '0') - borrow >= int(splitedString[1][i] - '0')) {
            temp = int(splitedString[0][i] - '0') - int(splitedString[1][i] - '0') - borrow;
            borrow = 0;
        }
        else {
            temp = int(splitedString[0][i] - '0') + 10 - int(splitedString[1][i] - '0') - borrow;
            borrow = 1;
        }

        tempChar = '0' + temp;
        finalInt.push_back(tempChar);
    }
    //消除前置0
    int idx = finalInt.length() - 1;
    while (finalInt[idx] == '0'&& idx!=0) {
        finalInt.erase(idx, 1);
        idx--;
    }
    if (negative) {
        finalInt += '-';
    }
    reverse(finalInt.begin(), finalInt.end());

    finalnum.append(finalInt);
    finalnum += '.';
    finalnum.append(finalFloat);
    delete[]splitedString;
    return numString(finalnum);
}
//两个数字相乘
numString numString::operator*(numString p) {
    int moveDot, nextDigit = 0;
    bool negative = false;
    string* splitedString;
    string finalnum = "";
    string str1, str2;
    str1 = this->num;
    str2 = p.num;
    //若其中一个数字为负，将负号消除，并标记负号
    if (this->num[0] != '-' && p.num[0] == '-') {
        negative = true;
        str2.erase(str2.begin());
    }
    if (this->num[0] == '-' && p.num[0] != '-') {
        negative = true;
        str1.erase(str1.begin());
    }
    //若两个数字都为负，将负号消除
    if (this->num[0] == '-' && p.num[0] == '-') {
        str1.erase(str1.begin());
        str2.erase(str2.begin());
    }
    splitedString = stringSplit(str1, str2, 0);
    string num1 = splitedString[0] + '.' + splitedString[2];
    string num2 = splitedString[1] + '.' + splitedString[3];
    moveDot = findDotPos(num1, num2);
    num1 = splitedString[0] + splitedString[2];
    num2 = splitedString[1] + splitedString[3];
    //结果最长的长度为两个数字长度的和
    vector<int> result(num1.length() + num2.length(), 0);
    if (num1.length() == 0 || num2.length() == 0) {
        return numString();
    }
    int num1Index = 0;
    int num2Index = 0;
    // 两个号码相乘
    for (int i = num1.length() - 1; i >= 0; i--)
    {
        nextDigit = 0;
        num2Index = 0;
        for (int j = num2.length() - 1; j >= 0; j--)
        {
            int sum = int(num1[i] - '0') * int(num2[j] - '0') + result[num1Index + num2Index] + nextDigit;
            nextDigit = sum / 10;
            result[num1Index + num2Index] = sum % 10;
            num2Index++;
        }
        if (nextDigit > 0)
            result[num1Index + num2Index] += nextDigit;
        num1Index++;
    }
//清除前置0
    int i = result.size() - 1;
    while (i >= 0 && result[i] == 0)
        i--;
    while (i >= 0)
        finalnum += to_string(result[i--]);
    int diff = finalnum.length() - moveDot;
    //移小数点，如长度不够则补足够的0
    if (moveDot != 0) {
        if (diff <= 0) {
            reverse(finalnum.begin(), finalnum.end());
            for (int i = 1; i <= -1 * diff + 1; i++)
                finalnum.push_back('0');
            reverse(finalnum.begin(), finalnum.end());
        }
        finalnum.insert(finalnum.length() - moveDot, ".");
    }
    if (negative) {
        finalnum.insert(0, "-");
    }
    delete[]splitedString;
    return numString(finalnum);
}
//两个数字相除 （除数不能太大）
numString numString::operator/(numString p) {
    //divisor is not big
    int nextDigit = 0;
    int dot1 = 0, dot2 = 0;
    string floatPoint;
    bool negative = false;
    string* splitedString;
    string str1, str2;
    str1 = this->num;
    str2 = p.num;
    //若其中一个数字为负，将负号消除，并标记负号
    if (this->num[0] != '-' && p.num[0] == '-') {
        negative = true;
        str2.erase(str2.begin());
    }
    if (this->num[0] == '-' && p.num[0] != '-') {
        negative = true;
        str1.erase(str1.begin());
    }
    //若两个数字都为负，将负号消除
    if (this->num[0] == '-' && p.num[0] == '-') {
        str1.erase(str1.begin());
        str2.erase(str2.begin());
    }
    splitedString = stringSplit(str1, str2, 0);
    string num1 = splitedString[0] + '.' + splitedString[2];
    string num2 = splitedString[1] + '.' + splitedString[3]; 
    for (int i = 0; i < int(num1.length()); i++) {
        if (num1[i] == '.') {
            dot1 = num1.length() - 1 - i;
        }
    }
    for (int i = 0; i < int(num2.length()); i++) {
        if (num2[i] == '.') {
            dot2 = num2.length() - 1 - i;
        }
    }
    num1 = splitedString[0] + splitedString[2];
    num2 = splitedString[1] + splitedString[3];
    if (num1.empty()) {
        return numString();
    }
    if (num2.empty()) {
        cout << "Divisor is 0. Math Error!" << endl;
        exit(0);
    }
    //移小数点位（将小数点消除）
    if (dot1 - dot2 > 0) {
        for (int i = 1; i <= dot1 - dot2; i++)
            num2.push_back('0');
    }
    if (dot2 - dot1 > 0) {
        for (int i = 1; i <= dot2 - dot1; i++)
            num1.push_back('0');
    }

    string ans;
    //寻找大于除数的被除数位置
    int idx = 0;
    int temp = num1[idx] - '0';
    while (temp < stoi(num2)) {
        if (idx + 1 >= int(num1.length()))
            break;
        temp = temp * 10 + (num1[++idx] - '0');
    }
    //除法
    while (int(num1.size()) > idx) {

        ans += (temp / stoi(num2)) + '0';
        temp = (temp % stoi(num2));
        if (idx + 1 >= int(num1.length()))
            break;
        temp = temp * 10 + num1[++idx] - '0';
    }
    //若无法整除，除到三位小数（第四位四舍五入）
    if (temp) {
        floatPoint = to_string(double(temp) / stod(num2));
        for (int i = 1; i < int(floatPoint.length()); i++) {
            if (i > 4)
                break;
            if (i==4 && floatPoint.length() > 5) {
                if (floatPoint[5] >= 53 && floatPoint[5] <= 57)
                    ans.push_back(int(floatPoint[i] - '0') + 1 + '0');
                else
                    ans.push_back(floatPoint[i]);
            }
            else
                ans.push_back(floatPoint[i]);
        }
    }    
    if (negative)
        ans.insert(0, "-");
    delete[]splitedString;
    return numString(ans);
}
//图形类中，面积和周长 & 表面积和体积 使用了多线程技术进行计算
//二维图形类
class shape2D {
public:
    virtual void calcArea() = 0;
    virtual string showResult() = 0;
protected:
//周长、面积
    string perimeter = "0";
    string area = "0";
};
class Rectangle :public shape2D {
public:
    Rectangle(string x = "0", string y = "0");
    void calcArea();
    void calcPerimeter();
    string showResult();
private:
//长度、宽度
    string length;
    string width;
};
//长方体构造函数
Rectangle::Rectangle(string x, string y) {
    length = x;
    width = y;
    //cout << "rectangle done" << endl;  
}
//计算面积函数
void Rectangle::calcArea() {
    numString A(length), B(width);
    numString C = A * B;
    area = C.num;
}
//计算周长函数
void Rectangle::calcPerimeter() {
    numString A(length), B(width), K("2.0");
    numString C = K *(A + B);
    perimeter = C.num;
}
//显示结果函数
string Rectangle::showResult() {
    string data="rectangle";
    //多线程技术
    thread th1(&Rectangle::calcArea, this);
    thread th2(&Rectangle::calcPerimeter, this);
    th1.join();
    th2.join();
    cout << "Area is " << area << endl << "Perimeter is " << perimeter << endl;
    data.append(",length:");
    data.append(length);
    data.append(",width:");
    data.append(width);
    data.append(",Area:");
    data.append(area);
    data.append(",Perimeter:");
    data.append(perimeter);
    return data;
}
//圆形类
class Circle :public shape2D {
public:
    Circle(string x = "0");
    void calcArea();
    void calcPerimeter();
    string showResult();
private:
//半径
    string radius;
};
//圆形构造函数
Circle::Circle(string x) {
    radius = x;
}
//计算面积函数
void Circle::calcArea() {
    numString A(radius), K(pi);
    numString C = K * A * A;
    area = C.num;
}
//计算周长函数
void Circle::calcPerimeter() {
    numString A(radius), K1(pi), K2("2.0");
    numString C = K1 * K2 * A;
    perimeter = C.num;
}
//显示结果函数
string Circle::showResult() {
    string data = "circle";
    thread th1(&Circle::calcArea, this);
    thread th2(&Circle::calcPerimeter, this);
    th1.join();
    th2.join();
    cout << "Area is " << area << endl << "Perimeter is " << perimeter << endl;
    data.append(",radius:");
    data.append(radius);
    data.append(",Area:");
    data.append(area);
    data.append(",Perimeter:");
    data.append(perimeter);
    return data;
}
//三角形类
class Triangle :public shape2D {
public:
    Triangle(string x = "0", string y = "0");
    void calcArea();
    string showResult();
private:
//底部长度、高度
    string base;
    string height;
};
//三角形构造函数
Triangle::Triangle(string x, string y) {
    base = x;
    height = y;
}
//计算面积函数
void Triangle::calcArea() {
    numString A(base), B(height), K1("0.5");
    numString C = K1* A * B;
    area = C.num;
}
//显示最终结果
string Triangle::showResult() {
    string data = "rectangle";
    calcArea();
    cout << "Area is " << area << endl;
    data.append(",base:");
    data.append(base);
    data.append(",height:");
    data.append(height);
    data.append(",Area:");
    data.append(area);
    return data;
}
//三维图形类
class shape3D {
public:
    virtual void calcSurfaceArea() = 0;
    virtual void calcVol() = 0;
    virtual string showResult() = 0;
protected:
//表面积、体积
    string surfaceArea = "0";
    string volume = "0";
};
//长方体类
class Cuboid :public shape3D {
public:
    Cuboid(string x = "0", string  y = "0", string  z = "0");
    void calcSurfaceArea();
    void calcVol();
    string showResult();
private:
//长度、宽度、高度
    string  length;
    string  width;
    string  height;
};
//长方体构造函数
Cuboid::Cuboid(string  x, string  y, string  z) {
    length = x;
    width = y;
    height = z;
}
//计算表面积
void Cuboid::calcSurfaceArea() {
    numString A(length), B(width), C(height), K("2.0");
    numString D = K * (A * B + A * C + B * C);
    surfaceArea = D.num;
}
//计算体积
void Cuboid::calcVol() {
    numString A(length), B(width), C(height);
    numString D = A * B * C;
    volume = D.num;
}
//显示最终结果
string Cuboid::showResult() {
    string data = "cuboid";
    thread th1(&Cuboid::calcSurfaceArea, this);
    thread th2(&Cuboid::calcVol, this);
    th1.join();
    th2.join();
    cout << "Surface Area is " << surfaceArea << endl << "Volume is " << volume << endl;
    data.append(",length:");
    data.append(length);
    data.append(",width:");
    data.append(width);
    data.append(",height:");
    data.append(height);
    data.append(",Surface Area:");
    data.append(surfaceArea);
    data.append(",volume:");
    data.append(volume);
    return data;
}
//圆柱体类
class Cylinder :public shape3D {
public:
    Cylinder(string  x = "0", string  y = "0");
    void calcSurfaceArea();
    void calcVol();
    string showResult();
private:
//高度、半径
    string height;
    string radius;
};
//圆柱体构造函数
Cylinder::Cylinder(string  x, string  y) {
    height = x;
    radius = y;
}
//计算表面积
void Cylinder::calcSurfaceArea() {
    numString A(radius), B(height), K1("2.0"), K2(pi);
    numString C = K2 * A * A + K1 * A * B;
    surfaceArea = C.num;
}
//计算体积
void Cylinder::calcVol() {
    numString A(radius), B(height), K1(pi);
    numString C = K1 * A * A * B;
    volume = C.num;
}
//显示最终结果
string Cylinder::showResult() {
    string data = "cylinder";
    thread th1(&Cylinder::calcSurfaceArea, this);
    thread th2(&Cylinder::calcVol, this);
    th1.join();
    th2.join();
    cout << "Surface Area is " << surfaceArea << endl << "Volume is " << volume << endl;
    data.append(",radius:");
    data.append(radius);
    data.append(",height:");
    data.append(height);
    data.append(",Surface Area:");
    data.append(surfaceArea);
    data.append(",volume:");
    data.append(volume);
    return data;
}
//球体类
class Sphere :public shape3D {
public:
    Sphere(string  x = "0");
    void calcSurfaceArea();
    void calcVol();
    string showResult();
private:
//半径
    string  radius;
};
//球体构造函数
Sphere::Sphere(string  x) {
    radius = x;
}
//计算表面积
void Sphere::calcSurfaceArea() {
    numString A(radius), K1(pi), K2("4.0");
    numString B = K2 * K1 * A * A;
    surfaceArea = B.num;
}
//计算体积
void Sphere::calcVol() {
    numString A(radius), K1(pi), K2(to_string(4.0/3.0));
    numString B = K2 * K1 * A * A * A;
    volume = B.num;
}
//计算最终结果
string Sphere::showResult() {
    string data = "sphere";
    thread th1(&Sphere::calcSurfaceArea, this);
    thread th2(&Sphere::calcVol, this);
    th1.join();
    th2.join();
    calcSurfaceArea();
    calcVol();
    cout << "Surface Area is " << surfaceArea << endl << "Volume is " << volume << endl;
    data.append(",radius:");
    data.append(radius);
    data.append(",Surface Area:");
    data.append(surfaceArea);
    data.append(",volume:");
    data.append(volume);
    return data;
}
//虚数类
class Complex {
public:
    Complex(string x= "0", string y="0");
    Complex operator+(Complex p);
    Complex operator*(Complex p);
    string real;
    string imag;
};
//虚数构造函数
Complex::Complex(string x, string y) {
    real = x;
    imag = y;
}
//虚数加法符号重载
Complex Complex::operator+(Complex p) {
    numString real1(this->real);
    numString real2(p.real);
    numString realPart = real1 + real2;
    numString imag1(this->imag);
    numString imag2(p.imag);
    numString imagPart = imag1 + imag2;
   return Complex(realPart.num, imagPart.num);

}
//虚数减法符号重载
Complex Complex::operator*(Complex p) {
    numString real1(this->real);
    numString real2(p.real);
    numString imag1(this->imag);
    numString imag2(p.imag);
    numString realPart = (real1 * real2) - (imag1 * imag2);
    numString imagPart = (real1 * imag2) + (imag1 * real2);
    return Complex(realPart.num, imagPart.num);
}
//系统类
class System {
public:
    System(char* str, bool file);
    void DisplayMainMenu();
    void initialize();
    void readHistory();
    void writeHistory();
    void deleteHistory();
    void basicNum();
    void complexNum();
    void shapes();
private:
    //系统开启日期时间、计算历史、是否文件输入
    string dateTime;
    queue<string> history;
    bool fileInput = true;
};
//系统构造函数
System::System(char* str, bool file) {
    string temp(str);
    dateTime = str;
    fileInput = file;
    ofstream calculatorHistory;
    calculatorHistory.open("D:/calculatorHistory.txt", ios_base::app);
    if (calculatorHistory.is_open()) {
        calculatorHistory << "Calculator Start Time: " << dateTime;
    }
    calculatorHistory.close();
}
//显示主菜单函数
void System::DisplayMainMenu() {
    cout << endl << "***Multi Purpose Calculator***" << endl;
    cout << "1. Four operations for basic numbers." << endl;
    cout << "2. Operations for complex numbers." << endl;
    cout << "3. 2D and 3D shapes." << endl;
    cout << "4. Check history." << endl;
    cout << "5. Clear history." << endl;
    cout << "6. Exit." << endl;
}
//系统功能初始化函数（给用户选择功能，并呼叫相关函数）
void System::initialize() {
    while (true) {
        DisplayMainMenu();
        int option;
        string s;
        cout << "Choose option: ";
        if (fileInput) {
            getline(fileInputCalc, s);
            option = stoi(s);
        }
        else
            cin >> option;
        if (history.size() > 2)
            writeHistory();
        switch (option) {
        case 1:
            basicNum();
            break;
        case 2:
            complexNum();
            break;
        case 3:
            shapes();
            break;
        case 4:
            writeHistory();
            readHistory();
            break;
        case 5:
            deleteHistory();
            break;
        case 6:
            writeHistory();
            fileInputCalc.close();
            exit(0);
        default:
            cout << "Enter a valid option!";
        }
    }
}
//处理实数四则运算输入函数
void System::basicNum() {
    string input, historyTemp;
    vector<string> inputNum;
    vector<int> addSub;
    int operation;
    bool cont = true;
    cout << "Enter number 1." << endl;
    if (fileInput)
        getline(fileInputCalc, input);
    else
        cin >> input;
    historyTemp += input;
    inputNum.push_back(input);
    cout << "Enter operation(1->+,2->-,3->*,4->/) " << endl;
    if (fileInput) {
        getline(fileInputCalc, input);
        operation = stoi(input);
    }
    else
        cin >> operation;
    cout << "Enter number 2." << endl;
    if (fileInput)
        getline(fileInputCalc, input);
    else
        cin >> input;
    if (operation == 3) {
        historyTemp += "*";
        historyTemp += input;
        numString A(inputNum[0]), B(input);
        numString C = A * B;
        inputNum[0] = C.num;
    }
    else if (operation == 4) {
        historyTemp += "/";
        historyTemp += input;
        numString A(inputNum[0]), B(input);
        numString C = A / B;
        inputNum[0] = C.num;
    }
    else if(operation==1){
        historyTemp += "+";
        historyTemp += input;
        inputNum.push_back(input);
        addSub.push_back(operation);
    }
    else if (operation == 2) {
        historyTemp += "-";
        historyTemp += input;
        inputNum.push_back(input);
        addSub.push_back(operation);
    }
    else{
        cout << "Invalid operation!" << endl;
        return;
    }
    while (true) {
        cout << "Continue?: " << endl;
        if (fileInput) {
            getline(fileInputCalc, input);
            cont = stoi(input);
        }
        else
            cin >> cont;
        if (cont) {
            cout << "Enter operation(1->+,2->-,3->*,4->/): " << endl;
            if (fileInput) {
                getline(fileInputCalc, input);
                operation = stoi(input);
            }
            else
                cin >> operation;
            cout << "Enter next number." << endl;
            if (fileInput)
                getline(fileInputCalc, input);
            else
                cin >> input;
            if (operation == 3) {
                historyTemp += "*";
                historyTemp += input;
                numString A(inputNum[inputNum.size()-1]), B(input);
                numString C = A * B;
                inputNum[inputNum.size()-1] = C.num;
            }
            else if (operation == 4) {
                historyTemp += "/";
                historyTemp += input;
                numString A(inputNum[inputNum.size() - 1]), B(input);
                numString C = A / B;
                inputNum[inputNum.size() - 1] = C.num;
            }
            else if (operation == 1) {
                historyTemp += "+";
                historyTemp += input;
                inputNum.push_back(input);
                addSub.push_back(operation);
            }
            else if (operation == 2) {
                historyTemp += "-";
                historyTemp += input;
                inputNum.push_back(input);
                addSub.push_back(operation);
            }
            else {
                cout << "Invalid operation!" << endl;
                return;
            }
        }
        else
            break;
    }
    historyTemp += "=";
    if (inputNum.size() == 1) {
        cout << "Ans is " << inputNum[0] << endl;
        historyTemp += inputNum[0];
    }
    else {
        int addSubIdx = 0;
        numString A(inputNum[0]);
        for (int i = 1; i < int(inputNum.size()); i++) {
            numString B(inputNum[i]);
            if (addSub[addSubIdx++] == 1)
                A = A + B;
            else
                A = A - B;
        }
        cout << "Ans is " << A.num << endl;
        historyTemp += A.num;
    }
    history.push(historyTemp);
}
//处理虚数运算输入函数
void System::complexNum() {
    string temp1, temp2, historyTemp;
    vector<string> addNum;
    vector<string> additionInput;
    vector<int> multiplyPos;
    vector<string> multiply;
    bool multiplySign = 0;
    cout << "Enter in the form of real1,imag1+*real2,imag2" << endl;
    if (fileInput)
        getline(fileInputCalc, temp1);
    else
        cin >> temp1;
    historyTemp.append(temp1);
    historyTemp.push_back('=');
    //split string according to +
    for (int i = 0; i < int(temp1.length());i++) {
        if (temp1[i] != '+') {
            if (temp1[i] == '*') {
                multiplySign = 1;
                temp2.push_back(',');
            }
            else
                temp2.push_back(temp1[i]);           
        }
        else {
            if (multiplySign) {
                multiplyPos.push_back(additionInput.size());
                multiplySign = 0;
            }
            additionInput.push_back(temp2);
            temp2.clear();
        }
    }
    if (multiplySign) {
        multiplyPos.push_back(additionInput.size());
        multiplySign = 0;
    }
    additionInput.push_back(temp2);
    temp1.clear();
    temp2.clear();
    //multiply vector size must be at least 4
    for (int i = 0; i < int(multiplyPos.size()); i++) {
        for (int j = 0; j < int(additionInput[multiplyPos[i]].length()); j++) {
            if (additionInput[multiplyPos[i]][j] != ',') {
                temp1.push_back(additionInput[multiplyPos[i]][j]);
            }
            else {
                multiply.push_back(temp1);
                temp1.clear();
            }
        }
        multiply.push_back(temp1);
        temp1.clear();
        Complex A(multiply[0], multiply[1]), B(multiply[2], multiply[3]);
        Complex result = A * B;
        if (multiply.size() > 4) {
            for (int k = 4; k < int(multiply.size()); k+=2) {
                Complex C(multiply[k], multiply[k + 1]);
                result = result * C;
            }
        }
        string Final = result.real;
        Final.push_back(',');
        Final += result.imag;
        additionInput[multiplyPos[i]] = Final;
        multiply.clear();
   }
    if (additionInput.size() > 1) {
        for (int i = 0; i < int(additionInput.size()); i++) {
            for (int j = 0; j < int(additionInput[i].length()); j++) {
                if (additionInput[i][j] != ',') {
                    temp2.push_back(additionInput[i][j]);
                }
                else {
                    addNum.push_back(temp2);
                    temp2.clear();
                }
            }
            addNum.push_back(temp2);
            temp2.clear();
        }
        Complex D(addNum[0], addNum[1]), E(addNum[2], addNum[3]);
        Complex finalResult = D + E;
        if (addNum.size() > 4) {
            for (int k = 4; k < int(addNum.size()); k += 2) {
                Complex F(addNum[k], addNum[k + 1]);
                finalResult = finalResult + F;
            }
        }
        cout << "real: " << finalResult.real << " imag:" << finalResult.imag << endl;
        historyTemp.append(finalResult.real);
        historyTemp.push_back(',');
        historyTemp.append(finalResult.imag);
    }
    else {
        cout << "real,imag: " << additionInput[0] << endl;
        historyTemp.append(additionInput[0]);
    }
    history.push(historyTemp);
}
//处理图形计算输入函数
void System::shapes() {
    string input, operators, shape, temp;
    vector<string> inputNum;
    string::iterator itr;
    cout << "Parameters: Rectangle(length,width), Circle(radius), Triangle(base,height), Cuboid(length,width,height), Cylinder(height,radius), Sphere(radius)" << endl;
    cout << "Enter in the form shape,parameter1,parameter2(if any),parameter3(if any)" << endl;
    if (fileInput)
        getline(fileInputCalc, input);
    else
        cin >> input;
    for ( itr = input.begin(); *itr != ','; itr++) {
        shape.push_back(*itr);
    }
    if (shape.compare("rectangle") == 0) {
        for (itr = itr + 1; *itr != ','; itr++)
            temp.push_back(*itr);
        inputNum.push_back(temp);
        temp.clear();
        for (itr = itr + 1; itr != input.end(); itr++)
            temp.push_back(*itr);
        inputNum.push_back(temp);
        Rectangle A(inputNum[0], inputNum[1]);
        history.push(A.showResult());
    }
    else if (shape.compare("circle") == 0) {
        for (itr = itr + 1; itr != input.end(); itr++)
            temp.push_back(*itr);
        inputNum.push_back(temp);
        Circle A(inputNum[0]);
        history.push(A.showResult());
    }
    else if (shape.compare("triangle") == 0) {
        for (itr = itr + 1; *itr != ','; itr++)
            temp.push_back(*itr);
        inputNum.push_back(temp);
        temp.clear();
        for (itr = itr + 1; itr != input.end(); itr++)
            temp.push_back(*itr);
        inputNum.push_back(temp);
        Triangle A(inputNum[0], inputNum[1]);
        history.push(A.showResult());
    }
    else if (shape.compare("cuboid") == 0) {
        for (int i = 0; i < 2; i++) {
            for (itr = itr + 1; *itr != ','; itr++)
                temp.push_back(*itr);
            inputNum.push_back(temp);
            temp.clear();
        }
        for (itr = itr + 1; itr != input.end(); itr++)
            temp.push_back(*itr);
        inputNum.push_back(temp);
        Cuboid A(inputNum[0], inputNum[1], inputNum[2]);
        history.push(A.showResult());
    }
    else if (shape.compare("cylinder") == 0) {
        for (itr = itr + 1; *itr != ','; itr++)
            temp.push_back(*itr);
        inputNum.push_back(temp);
        temp.clear();
        for (itr = itr + 1; itr != input.end(); itr++)
            temp.push_back(*itr);
        inputNum.push_back(temp);
        Cylinder A(inputNum[0], inputNum[1]);
        history.push(A.showResult());
    }
    else if (shape.compare("sphere") == 0) {
        for (itr = itr + 1; itr != input.end(); itr++)
            temp.push_back(*itr);
        inputNum.push_back(temp);
        Sphere A(inputNum[0]);
        history.push(A.showResult());
    }
    else
        cout << "Wrong Input!" << endl;
}
//读入并显示计算历史函数
void System::readHistory() {
    ifstream calculatorHistory;
    string temp;
    cout << "History" << endl;
    calculatorHistory.open("D:/calculatorHistory.txt");
    if (calculatorHistory.is_open()) {
        while (calculatorHistory.good()) {
            getline(calculatorHistory, temp);
            cout << temp << endl;
        }
    }
    calculatorHistory.close();
}
//将计算历史写入文件函数
void System::writeHistory() {
    ofstream calculatorHistory;
    calculatorHistory.open("D:/calculatorHistory.txt", ios_base::app);
    if (calculatorHistory.is_open()) {
        while (!history.empty()) {
            calculatorHistory << history.front() << endl;
            history.pop();
        }
    }
    calculatorHistory.close();
}
//删除计算历史函数
void System::deleteHistory() {
    ofstream calculatorHistory;
    calculatorHistory.open("D:/calculatorHistory.txt", ios_base::out);
    calculatorHistory.close();
    cout << "History is cleared" << endl;
}
//主函数
int main()
{
    //此刻日期时间
    time_t now = time(0);
    char* dt = ctime(&now);
    bool file;
    string str;
    //是否文件输入
    cout << "File Input or not: ";
    getline(fileInputCalc, str);
    file = stoi(str);
    getline(fileInputCalc, str);
    //启动计算器系统
    System A(dt, file);
    A.initialize();   
}