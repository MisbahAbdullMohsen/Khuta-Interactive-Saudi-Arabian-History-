import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'l10n/app_localizations_delegate.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
//import 'package:ksa_app/models/event_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString('selectedLanguage') ?? 'ar';
  bool isDarkMode =
      prefs.getBool('isDarkMode') ?? false; // استرجاع حالة الوضع المظلم

  runApp(MyApp(languageCode: languageCode, isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final String languageCode;
  final bool isDarkMode; // إضافة الوضع المظلم كخاصية

  const MyApp(
      {super.key, required this.languageCode, required this.isDarkMode});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;
  late bool isDarkMode; // متغير للتحكم في الوضع المظلم

  @override
  void initState() {
    super.initState();
    _locale = Locale(widget.languageCode);
    isDarkMode = widget.isDarkMode; // استرجاع حالة الوضع المظلم
  }

  // تغيير اللغة
  void _changeLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', languageCode);

    setState(() {
      _locale = Locale(languageCode);
    });
  }

  // تغيير حالة الوضع المظلم
  void _toggleDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = !isDarkMode; // قلب الوضع الحالي
    });
    await prefs.setBool('isDarkMode', isDarkMode); // حفظ حالة الوضع المظلم
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      theme: ThemeData(
        fontFamily: 'Cairo',
        brightness: isDarkMode
            ? Brightness.dark
            : Brightness.light, // تحديد الوضع المظلم أو الفاتح
      ),
      supportedLocales: const [
        Locale('ar', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizationsDelegate(),
      ],
      home: HomePage(
        changeLanguage: _changeLanguage,
        toggleDarkMode: _toggleDarkMode, // تمرير دالة تغيير الوضع المظلم
        isDarkMode: isDarkMode, // تمرير حالة الوضع المظلم
      ),
    );
  }
}

List<Map<String, dynamic>> likedEvents = [];

// الرئيسية Page
class HomePage extends StatelessWidget {
  final Function(String) changeLanguage;
  final VoidCallback toggleDarkMode; // دالة للتبديل بين الوضعين
  final bool isDarkMode; // حالة الوضع المظلم

  const HomePage({
    super.key,
    required this.changeLanguage,
    required this.toggleDarkMode,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    String backgroundImage = localization.locale.languageCode == 'ar'
        ? 'assets/Ar.jpg' // صورة للخلفية عند اختيار اللغة العربية
        : 'assets/Am.jpg'; // صورة للخلفية عند اختيار اللغة الإنجليزية
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Button at the bottom center
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimelinePage(
                        changeLanguage: changeLanguage,
                        toggleDarkMode: toggleDarkMode, // تمرير toggleDarkMode
                        isDarkMode: isDarkMode, // تمرير isDarkMode
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Beige tone
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                ),
                child: Text(
                  localization.locale.languageCode == 'ar'
                      ? "لنخطـــو معــاً"
                      : "Let's Move Forward Together",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimelinePage extends StatefulWidget {
  final Function(String) changeLanguage;
  final VoidCallback toggleDarkMode;
  final bool isDarkMode;

  const TimelinePage({
    super.key,
    required this.changeLanguage,
    required this.toggleDarkMode,
    required this.isDarkMode,
  });

  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  String searchText = ''; // متغير لتخزين نص البحث

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final textAlign = localization.locale.languageCode == 'ar'
        ? TextAlign.right
        : TextAlign.left;

    final filteredEvents = _events(localization).where((event) {
      // تصفية الأحداث بناءً على نص البحث
      return event['title'].toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color.fromRGBO(92, 64, 51, 1.0), // لون رأس الصفحة الأخضر
        title: Text(
          localization.timeline,
          style: const TextStyle(
            fontSize: 22, // تكبير حجم النص
            color: Colors.white, // تغيير اللون إلى الأبيض
            fontWeight: FontWeight.bold,
          ),
          textAlign: textAlign,
        ),
        iconTheme: const IconThemeData(
            color: Colors.white), // تغيير لون الأيقونة إلى الأبيض
      ),
      drawer: AppDrawer(
        changeLanguage: widget.changeLanguage,
        toggleDarkMode: widget.toggleDarkMode,
        isDarkMode: widget.isDarkMode,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    localization.locale.languageCode == 'ar'
                        ? "أحداث المملكة العربية السعودية منذ التأسيس"
                        : "The History of Saudi Arabia Since Its Founding",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff5C4033),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xffF5F5F5), // لون الخلفية
                    labelText: localization.locale.languageCode == 'ar'
                        ? 'بحث'
                        : 'Search',
                    labelStyle: const TextStyle(
                        fontFamily: 'Cairo'), // نمط تسمية مربع البحث
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xff5C4033)), // أيقونة البحث
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          26.0), // جعل حواف مربع البحث دائرية
                    ),
                  ),
                  textAlign: textAlign,
                  onChanged: (value) {
                    setState(() {
                      searchText = value; // تحديث نص البحث
                    });
                  },
                ),
                const SizedBox(height: 20), // مسافة بعد مربع البحث
                filteredEvents.isEmpty && searchText.isNotEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد نتائج',
                          style: TextStyle(color: Colors.red, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount:
                            filteredEvents.length, // استخدام الأحداث المفلترة
                        itemBuilder: (context, index) {
                          Map<String, dynamic> event = filteredEvents[index];
                          return EventItem(
                            index: index,
                            image: event['image'],
                            date: event['date'],
                            title: event['title'],
                            description: event['description'],
                            detailImage: event['detailImage'],
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<Map<String, dynamic>> _events(AppLocalizations localization) {
  return [
    {
      'image': 'assets/100.webp',
      'date': '22/02/1727',
      'title': localization.locale.languageCode == 'ar'
          ? 'تأسيس الدولة السعودية الأولى'
          : 'Founding of the First Saudi State',
      'description': localization.locale.languageCode == 'ar'
          ? 'تم تأسيس الدولة السعودية الأولى عبر تحالف بين محمد بن سعود والشيخ محمد بن عبدالوهاب، مؤسس الدعوة الوهابية، في الدرعية. هذا التحالف أسس دولة ذات طابع ديني وسياسي. أصبحت الدرعية عاصمة للدولة وبدأت فترة من الاستقرار والتوسع.'
          : 'The First Saudi State was founded through an alliance between Muhammad bin Saud and Sheikh Muhammad bin Abdulwahhab, the founder of the Wahhabi movement, in Diriyah. This alliance established a state with religious and political authority. Diriyah became the capital, marking a period of stability and expansion.',
      'detailImage': 'assets/01_detail.png'
    },
    {
      'image': 'assets/222.jpg',
      'date': '24/06/1824',
      'title': localization.locale.languageCode == 'ar'
          ? 'تأسيس الدولة السعودية الثانية'
          : 'Founding of the Second Saudi State',
      'description': localization.locale.languageCode == 'ar'
          ? 'بعد سقوط الدولة السعودية الأولى، أعاد تركي بن عبدالله بن محمد بن سعود تأسيس الدولة السعودية الثانية في الرياض. شكلت هذه الخطوة بداية لفترة جديدة من الاستقرار والحكم في نجد. سعى الحكام الجدد إلى إعادة إحياء الهيبة السياسية والدينية للدولة.'
          : 'After the fall of the First Saudi State, Turki bin Abdullah bin Muhammad bin Saud re-established the Second Saudi State in Riyadh. This move marked the beginning of a new period of stability and governance in Najd, with the rulers aiming to restore the state’s political and religious stature.',
      'detailImage': 'assets/03_detail.jpg'
    },
    {
      'image': 'assets/333.jpg',
      'date': '15/01/1902',
      'title': localization.locale.languageCode == 'ar'
          ? 'تأسيس الدولة السعودية الثالثة'
          : 'Founding of the Third Saudi State',
      'description': localization.locale.languageCode == 'ar'
          ? 'نجح الملك عبدالعزيز آل سعود في توحيد مناطق شبه الجزيرة العربية تحت اسم المملكة العربية السعودية. هذا التوحيد جمع المناطق المختلفة تحت حكم واحد، مما أدى إلى بداية فترة من الاستقرار والتنمية. شكلت المملكة الجديدة بداية عهد جديد في تاريخ المنطقة.'
          : 'King Abdulaziz Al Saud succeeded in uniting the regions of the Arabian Peninsula under the name of the Kingdom of Saudi Arabia. This unification brought diverse areas under a single rule, marking the beginning of a new era of stability and development in the region.',
      'detailImage': 'assets/05_detail.png'
    },
    {
      'image': 'assets/2.jpg',
      'date': '29/05/1933',
      'title': localization.locale.languageCode == 'ar'
          ? 'اكتشاف النفط'
          : 'Discovery of Oil',
      'description': localization.locale.languageCode == 'ar'
          ? 'اكتشاف النفط في بئر الدمام رقم 7 أحدث تحولاً اقتصادياً هائلاً للمملكة العربية السعودية. أصبح النفط عنصراً أساسياً في الاقتصاد الوطني، وساهم في تحويل المملكة إلى واحدة من أكبر الدول المنتجة والمصدرة للنفط. كان لهذا الاكتشاف تأثير كبير على التنمية الاقتصادية.'
          : 'The discovery of oil in Well No. 7 in Dammam brought a significant economic transformation to Saudi Arabia. Oil became a key component of the national economy, turning the Kingdom into one of the largest oil producers and exporters. This discovery had a profound impact on economic development.',
      'detailImage': 'assets/06_detail.jpg'
    },
    {
      'image': 'assets/3.webp',
      'date': '22/03/1945',
      'title': localization.locale.languageCode == 'ar'
          ? 'تأسيس جامعة الدول العربية'
          : 'Founding of the Arab League',
      'description': localization.locale.languageCode == 'ar'
          ? 'المملكة كانت من بين الدول المؤسسة لجامعة الدول العربية، التي تهدف إلى تعزيز التعاون بين الدول العربية. أسهمت المملكة في صياغة السياسات الإقليمية ودعم القضايا العربية المشتركة. شكلت هذه المنظمة منصة للتعاون والتنسيق في الشؤون السياسية والاقتصادية والثقافية.'
          : 'Saudi Arabia was among the founding nations of the Arab League, which aims to enhance cooperation among Arab states. The Kingdom contributed to regional policy formulation and supported shared Arab causes. The organization became a platform for cooperation in political, economic, and cultural affairs.',
      'detailImage': 'assets/07_detail.jpg'
    },
    {
      'image': 'assets/4.jpeg',
      'date': '26/06/1945',
      'title': localization.locale.languageCode == 'ar'
          ? 'الانضمام إلى الأمم المتحدة'
          : 'Joining the United Nations',
      'description': localization.locale.languageCode == 'ar'
          ? 'انضمت المملكة كعضو مؤسس إلى الأمم المتحدة بعد الحرب العالمية الثانية.'
          : 'The Kingdom joined the United Nations as a founding member after World War II.',
      'detailImage': 'assets/08_detail.png'
    },
    {
      'image': 'assets/6.jpg',
      'date': '28/03/1965',
      'title': localization.locale.languageCode == 'ar'
          ? 'الملك فيصل يعلن سياسة النفط'
          : 'King Faisal Announces Oil Policy',
      'description': localization.locale.languageCode == 'ar'
          ? 'أعلن الملك فيصل حظر تصدير النفط خلال حرب أكتوبر 1973.'
          : 'King Faisal announced an oil export ban during the October 1973 War.',
      'detailImage': 'assets/09_detail.jpg'
    },
    {
      'image': 'assets/8.jpg',
      'date': '25/04/2016',
      'title': localization.locale.languageCode == 'ar'
          ? 'إعلان رؤية 2030'
          : 'Announcement of Vision 2030',
      'description': localization.locale.languageCode == 'ar'
          ? 'رؤية 2030 هي خطة استراتيجية تهدف إلى تقليل الاعتماد على النفط وتنويع الاقتصاد.'
          : 'Vision 2030 is a strategic plan aimed at reducing reliance on oil and diversifying the economy.',
      'detailImage': 'assets/10_detail.jpg'
    },
    {
      'image': 'assets/12.jpeg',
      'date': '24/10/2017',
      'title': localization.locale.languageCode == 'ar'
          ? 'تطوير مشاريع نيوم'
          : 'Development of NEOM Projects',
      'description': localization.locale.languageCode == 'ar'
          ? 'نيوم هو مشروع مدينة ذكية ومستدامة في شمال غرب المملكة.'
          : 'NEOM is a smart, sustainable city project in the northwest of the Kingdom.',
      'detailImage': 'assets/12_detail.jpg'
    },
    {
      'image': 'assets/10.jpg',
      'date': '26/09/2017',
      'title': localization.locale.languageCode == 'ar'
          ? 'السماح للنساء بقيادة السيارات'
          : 'Women Allowed to Drive',
      'description': localization.locale.languageCode == 'ar'
          ? 'جاء هذا القرار كجزء من الإصلاحات الاجتماعية في المملكة.'
          : 'This decision was part of the Kingdom’s social reforms.',
      'detailImage': 'assets/13_detail.jpg'
    },
    {
      'image': 'assets/345.png',
      'date': '07/04/2017',
      'title': localization.locale.languageCode == 'ar'
          ? 'مشروع القدية'
          : 'Qiddiya Project',
      'description': localization.locale.languageCode == 'ar'
          ? 'مشروع القدية يهدف إلى تحويل السعودية إلى وجهة سياحية عالمية.'
          : 'The Qiddiya Project aims to turn Saudi Arabia into a global tourist destination.',
      'detailImage': 'assets/14_detail.jpeg'
    },
    {
      'image': 'assets/19.jpg',
      'date': '19/03/2019',
      'title': localization.locale.languageCode == 'ar'
          ? 'مبادرة الرياض الخضراء'
          : 'Riyadh Green Initiative',
      'description': localization.locale.languageCode == 'ar'
          ? 'تشمل مبادرة الرياض الخضراء مشاريع لتحسين الغطاء النباتي.'
          : 'The Riyadh Green Initiative includes projects to improve vegetation.',
      'detailImage': 'assets/17_detail.png'
    },
    {
      'image': 'assets/15.webp',
      'date': '21/11/2020',
      'title': localization.locale.languageCode == 'ar'
          ? 'قمة مجموعة العشرين'
          : 'G20 Summit',
      'description': localization.locale.languageCode == 'ar'
          ? 'استضافت المملكة قمة مجموعة العشرين في الرياض.'
          : 'The Kingdom hosted the G20 Summit in Riyadh.',
      'detailImage': 'assets/16_detail.jpg'
    },
    {
      'image': 'assets/2131.jpeg',
      'date': '27/03/2021',
      'title': localization.locale.languageCode == 'ar'
          ? 'برنامج تنمية القدرات البشرية'
          : 'Human Capability Development Program',
      'description': localization.locale.languageCode == 'ar'
          ? 'يركز البرنامج على تطوير مهارات وقدرات المواطنين.'
          : 'The program focuses on developing the skills and capabilities of citizens.',
      'detailImage': 'assets/18_detail.jpg'
    },
  ];
}

// تعريف ويدجت عنصر الحدث كـ StatefulWidget لأننا سنحتاج لتحديث حالة الإعجاب
class EventItem extends StatefulWidget {
  final int index; // فهرس العنصر في القائمة
  final String image; // رابط الصورة التي تعرض للحدث
  final String date; // تاريخ الحدث بصيغة يوم/شهر/سنة
  final String title; // عنوان الحدث
  final String description; // وصف الحدث
  final String detailImage; // رابط صورة إضافية تعرض في تفاصيل الحدث

  // المُنشئ لتلقي القيم المطلوبة وتعيينها
  const EventItem({
    super.key,
    required this.index,
    required this.image,
    required this.date,
    required this.title,
    required this.description,
    required this.detailImage,
  });

  @override
  _EventItemState createState() =>
      _EventItemState(); // إنشاء الحالة التي تتحكم في هذا الويدجت
}

class _EventItemState extends State<EventItem> {
  bool isLiked = false; // حالة الإعجاب، تحدد ما إذا كان الحدث معجب به أم لا

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context); // الحصول على الترجمة
    // تقسيم التاريخ إلى يوم وشهر وسنة باستخدام الفاصل '/'
    final parts = widget.date.split('/');
    final day = parts[0]; // اليوم
    final monthName = _getMonthName(parts[1], context);
    // تحويل رقم الشهر إلى اسمه
    final year = parts[2]; // السنة

    return Container(
      margin: const EdgeInsets.only(
          bottom: 30), // إضافة مسافة من الأسفل بين العناصر
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // محاذاة العناصر في بداية الصف
        children: [
          // قسم لعرض تاريخ الحدث على الجانب الأيسر
          SizedBox(
            width: 70, // عرض ثابت للحاوية
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // محاذاة النصوص في المنتصف
              children: [
                const SizedBox(
                    height: 70), // مسافة إضافية من الأعلى لتحريك التاريخ لأسفل
                Text(
                  day, // عرض اليوم
                  style: const TextStyle(
                    fontSize: 20, // حجم الخط
                    fontWeight: FontWeight.bold, // سمك الخط
                    color: Color(0xff5C4033), // اللون الأخضر لتاريخ الحدث
                  ),
                ),
                Text(
                  monthName, // عرض الشهر
                  style: const TextStyle(
                    fontSize: 23, // حجم الخط
                    fontWeight: FontWeight.bold, // سمك الخط
                    color: Color(0xff5C4033), // اللون الأخضر لتاريخ الحدث
                  ),
                ),
                Text(
                  year, // عرض السنة
                  style: const TextStyle(
                    fontSize: 20, // حجم الخط
                    fontWeight: FontWeight.bold, // سمك الخط
                    color: Color(0xff5C4033), // اللون الأخضر لتاريخ الحدث
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10), // مسافة بين التاريخ والصورة
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // محاذاة النصوص في بداية العمود
              children: [
                Stack(
                  children: [
                    // عرض صورة الحدث
                    Container(
                      height: 270, // ارتفاع الصورة
                      width: double.infinity, // عرض الصورة يملأ المساحة المتاحة
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(20), // زوايا دائرية للصورة
                        image: DecorationImage(
                          image: AssetImage(
                              widget.image), // تحميل الصورة من الأصول
                          fit: BoxFit.cover, // ملء الصورة المساحة المتاحة
                        ),
                      ),
                    ),
                    // عنوان الحدث فوق الصورة في الزاوية العليا اليمين
                    Positioned(
                      top: 10, // المسافة من أعلى الصورة
                      right: 10, // المسافة من يمين الصورة
                      child: Container(
                        padding:
                            const EdgeInsets.all(10), // إضافة حشو حول العنوان
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(0.7), // خلفية بيضاء نصف شفافة
                          borderRadius:
                              BorderRadius.circular(10), // زوايا دائرية للخلفية
                        ),
                        child: Text(
                          widget.title, // عرض عنوان الحدث
                          style: const TextStyle(
                            color: Colors.black, // لون النص
                            fontSize: 16, // حجم الخط
                            fontWeight: FontWeight.bold, // سمك الخط
                          ),
                        ),
                      ),
                    ),
                    // زر "انقر لعرض التفاصيل" في أسفل يسار الصورة
                    Positioned(
                      bottom: 10, // المسافة من أسفل الصورة
                      left: 10, // المسافة من يسار الصورة
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xff5C4033), // لون النص
                          side: const BorderSide(
                            color: Color(0xff5C4033), // لون الحدود
                            width: 2, // سمك الحدود
                          ),
                          backgroundColor: Colors.white, // خلفية الزر
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // زوايا دائرية للزر
                          ),
                        ),
                        onPressed: () {
                          // عرض تفاصيل الحدث في نافذة منبثقة عند الضغط
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    20), // زوايا دائرية للنافذة
                              ),
                              title: Align(
                                alignment:
                                    Alignment.center, // محاذاة العنوان في الوسط
                                child: Text(
                                  widget.title, // عنوان الحدث
                                  style: const TextStyle(
                                    fontSize: 22, // حجم الخط
                                    fontWeight: FontWeight.bold, // سمك الخط
                                    color: Color(0xff5C4033), // لون العنوان
                                  ),
                                  textAlign:
                                      TextAlign.center, // محاذاة النص في الوسط
                                ),
                              ),
                              content: SizedBox(
                                width: double.maxFinite, // عرض نافذة التفاصيل
                                child: Column(
                                  mainAxisSize: MainAxisSize
                                      .min, // عرض المحتوى بأقل حجم ممكن
                                  crossAxisAlignment: CrossAxisAlignment
                                      .end, // محاذاة النصوص من اليمين لليسار
                                  children: [
                                    const SizedBox(
                                        height: 10), // مسافة من الأعلى
                                    Align(
                                      alignment: localization
                                                  .locale.languageCode ==
                                              'ar'
                                          ? Alignment
                                              .centerRight // محاذاة النص إلى اليمين للعربية
                                          : Alignment
                                              .centerLeft, // محاذاة النص إلى اليسار للإنجليزية
                                      child: Text(
                                        localization.locale.languageCode == 'ar'
                                            ? 'وصف الحدث'
                                            : 'Event Description',
                                        style: const TextStyle(
                                          fontSize: 20, // حجم الخط
                                          fontWeight:
                                              FontWeight.bold, // سمك الخط
                                          color:
                                              Color(0xff5C4033), // لون العنوان`
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment
                                          .centerLeft, // محاذاة النص إلى اليمين
                                      child: Text(
                                        widget.description, // وصف الحدث
                                        style: const TextStyle(
                                          fontSize: 16, // حجم الخط
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        height: 10), // مسافة من الأسفل
                                    Align(
                                      alignment: Alignment
                                          .centerRight, // محاذاة الصورة إلى اليمين
                                      child: SizedBox(
                                        width: double.infinity, // عرض الصورة
                                        height: 250, // ارتفاع الصورة
                                        child: Image.asset(
                                          widget
                                              .detailImage, // تحميل صورة التفاصيل
                                          fit: BoxFit
                                              .cover, // ملء الصورة المساحة المتاحة
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        const Color(0xff5C4033), // لون النص
                                  ),
                                  onPressed: () => Navigator.pop(
                                      context), // إغلاق النافذة عند الضغط
                                  child: Text(
                                    localization.locale.languageCode == 'ar'
                                        ? "إغلاق"
                                        : "Close", // نص الزر
                                    style: const TextStyle(
                                      fontSize: 16, // حجم الخط
                                      fontWeight: FontWeight.bold, // سمك الخط
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          localization.locale.languageCode == 'ar'
                              ? "انقر لعرض التفاصيل"
                              : "Click for Details", // نص الزر
                          style: const TextStyle(
                            fontSize: 15, // حجم الخط
                            fontWeight: FontWeight.bold, // سمك الخط
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // أزرار الإعجاب والمشاركة تحت الصورة
                Container(
                  margin: const EdgeInsets.only(top: 10), // مسافة من الأعلى
                  child: Align(
                    alignment:
                        Alignment.centerRight, // محاذاة الأزرار إلى اليمين
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min, // عرض الأزرار بأقل حجم ممكن
                      children: [
                        // زر الإعجاب
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color:
                                isLiked ? Colors.red : const Color(0xff5C4033),
                          ),
                          onPressed: () {
                            setState(() {
                              isLiked = !isLiked; // تبديل حالة الإعجاب
                            });

                            if (isLiked) {
                              // إضافة الحدث إلى قائمة الإعجابات
                              likedEvents.add({
                                'image': widget.image,
                                'date': widget.date,
                                'title': widget.title,
                                'description': widget.description,
                                'detailImage': widget.detailImage,
                              });
                            } else {
                              // إزالة الحدث من قائمة الإعجابات إذا تم إلغاء الإعجاب
                              likedEvents.removeWhere(
                                  (event) => event['title'] == widget.title);
                            }
                          },
                        ),
                        // زر المشاركة
                        IconButton(
                          icon: const Icon(Icons.share),
                          color: const Color(0xff5C4033), // أيقونة المشاركة
                          onPressed: () {
                            // عرض نافذة منبثقة لمشاركة الحدث عند الضغط
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text(
                                        localization.locale.languageCode == 'ar'
                                            ? "مشاركة الحدث"
                                            : "Share Event", // عنوان النافذة المنبثقة
                                        style: const TextStyle(
                                          fontSize: 18, // حجم الخط
                                          fontWeight:
                                              FontWeight.bold, // سمك الخط
                                          color:
                                              Color(0xff5C4033), // لون العنوان
                                        ),
                                      ),
                                      content: Text(
                                        localization.locale.languageCode == 'ar'
                                            ? "هل ترغب في مشاركة هذا الحدث؟"
                                            : "Do you want to share this event?", // نص المحتوى
                                        style: const TextStyle(
                                          fontSize: 16, // حجم الخط
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text(
                                            localization.locale.languageCode ==
                                                    'ar'
                                                ? 'إلغاء'
                                                : 'Cancel',
                                          ),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                        ),
                                        TextButton(
                                          child: Text(
                                            localization.locale.languageCode ==
                                                    'ar'
                                                ? 'مشاركة'
                                                : 'Share',
                                          ),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                            // Proceed with the share functionality
                                          },
                                        ),
                                      ],
                                    ));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// دالة لتحويل رقم الشهر إلى اسمه
String _getMonthName(String monthNumber, BuildContext context) {
  final localization = AppLocalizations.of(context); // الحصول على الترجمة

  switch (monthNumber) {
    case '01':
      return localization.locale.languageCode == 'ar' ? 'يناير' : 'Jan';
    case '02':
      return localization.locale.languageCode == 'ar' ? 'فبراير' : 'Feb';
    case '03':
      return localization.locale.languageCode == 'ar' ? 'مارس' : 'Mar';
    case '04':
      return localization.locale.languageCode == 'ar' ? 'أبريل' : 'Apr';
    case '05':
      return localization.locale.languageCode == 'ar' ? 'مايو' : 'May';
    case '06':
      return localization.locale.languageCode == 'ar' ? 'يونيو' : 'Jun';
    case '07':
      return localization.locale.languageCode == 'ar' ? 'يوليو' : 'Jul';
    case '08':
      return localization.locale.languageCode == 'ar' ? 'أغسطس' : 'Aug';
    case '09':
      return localization.locale.languageCode == 'ar' ? 'سبتمبر' : 'Sep';
    case '10':
      return localization.locale.languageCode == 'ar' ? 'أكتوبر' : 'Oct';
    case '11':
      return localization.locale.languageCode == 'ar' ? 'نوفمبر' : 'Nov';
    case '12':
      return localization.locale.languageCode == 'ar' ? 'ديسمبر' : 'Dec';
    default:
      return localization.locale.languageCode == 'ar' ? 'غير معروف' : 'Unknown';
  }
}

// الإعجابات Page
class LikesPage extends StatelessWidget {
  final Function(String) changeLanguage;
  final VoidCallback toggleDarkMode;
  final bool isDarkMode;

  const LikesPage({
    super.key,
    required this.changeLanguage,
    required this.toggleDarkMode,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff5C4033),
        title: Text(
          localization.locale.languageCode == 'ar' ? 'الإعجابات' : 'Likes',
          style: const TextStyle(
            color: Color.fromARGB(255, 227, 227, 227),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(
        changeLanguage: changeLanguage,
        toggleDarkMode: toggleDarkMode,
        isDarkMode: isDarkMode,
      ),
      body: likedEvents.isEmpty
          ? Center(
              child: Text(
                localization.locale.languageCode == 'ar'
                    ? 'لم تقم بالإعجاب بأي أحداث بعد'
                    : 'You have not liked any events yet',
                style: const TextStyle(fontSize: 24),
              ),
            )
          : ListView.builder(
              itemCount: likedEvents.length,
              itemBuilder: (context, index) {
                final event = likedEvents[index];
                return ListTile(
                  leading: Container(
                    height: 100, // ضبط ارتفاع الصورة
                    width: 100, // ضبط عرض الصورة
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(event['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(event['title']),
                  subtitle: Text(event['date']),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(event['title']),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(event['description']),
                            Container(
                              height: 250,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(event['detailImage']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              localization.locale.languageCode == 'ar'
                                  ? 'إغلاق'
                                  : 'Close',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

// الإعدادات Page
class SettingsPage extends StatefulWidget {
  final Function(String) changeLanguage;
  final VoidCallback toggleDarkMode; // إضافة toggleDarkMode
  final bool isDarkMode; // إضافة isDarkMode

  const SettingsPage({
    super.key,
    required this.changeLanguage,
    required this.toggleDarkMode, // تمرير toggleDarkMode
    required this.isDarkMode, // تمرير isDarkMode
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isDarkMode;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'العربية';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = widget.isDarkMode; // استخدام الحالة المظلمة من widget
      _notificationsEnabled = (prefs.getBool('notificationsEnabled') ?? true);
      _selectedLanguage = (prefs.getString('selectedLanguage') ?? 'ar') == 'ar'
          ? 'العربية'
          : 'English';
    });
  }

  _updateDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
      widget.toggleDarkMode(); // استدعاء toggleDarkMode من widget
      prefs.setBool('isDarkMode', value);
    });
  }

  _updateNotifications(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = value;
      prefs.setBool('notificationsEnabled', value);
    });
  }

  _updateLanguage(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = value;
      prefs.setString('selectedLanguage', value == 'العربية' ? 'ar' : 'en');
    });
    widget.changeLanguage(value == 'العربية' ? 'ar' : 'en');
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color.fromRGBO(92, 64, 51, 1.0), // نفس لون الهيدر السابق
        title: Text(
          localization.settings,
          style: const TextStyle(
            fontSize: 22, // تكبير حجم النص
            color: Colors.white, // تغيير اللون إلى الأبيض
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
            color: Colors.white), // تغيير لون الأيقونة إلى الأبيض
        leading: IconButton(
          icon: const Icon(Icons.menu), // تغيير الأيقونة لتكون مثل التايم لاين
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // الزر لتفعيل/إلغاء تفعيل الوضع المظلم
          SwitchListTile(
            title: Text(localization.darkMode),
            value: _isDarkMode,
            onChanged: (bool value) {
              _updateDarkMode(value); // تحديث حالة الوضع المظلم
            },
            activeColor: const Color(0xff5C4033), // تغيير اللون إلى البني
          ),
          SwitchListTile(
            title: Text(localization.notifications),
            value: _notificationsEnabled,
            onChanged: _updateNotifications,
            activeColor: const Color(0xff5C4033), // تغيير اللون إلى البني
          ),
          ListTile(
            title: Text(localization.switchLanguage),
            subtitle: Text(_selectedLanguage),
            onTap: () {
              _showLanguageDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('العربية'),
                onTap: () {
                  _updateLanguage('العربية');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('English'),
                onTap: () {
                  _updateLanguage('English');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/*

// الإعدادات Page
class SettingsPage extends StatefulWidget {
  final Function(String) changeLanguage;
  final VoidCallback toggleDarkMode; // إضافة toggleDarkMode
  final bool isDarkMode; // إضافة isDarkMode

  const SettingsPage({
    Key? key,
    required this.changeLanguage,
    required this.toggleDarkMode, // تمرير toggleDarkMode
    required this.isDarkMode, // تمرير isDarkMode
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isDarkMode;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'العربية';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
 _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = widget.isDarkMode; // استخدام الحالة المظلمة من widget
      _notificationsEnabled = (prefs.getBool('notificationsEnabled') ?? true);
      _selectedLanguage = (prefs.getString('selectedLanguage') ?? 'ar') == 'ar'
          ? 'العربية'
          : 'English';
    });
  }

  _updateDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
      widget.toggleDarkMode(); // استدعاء toggleDarkMode من widget
      prefs.setBool('isDarkMode', value);
    });
  }

  _updateNotifications(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = value;
      prefs.setBool('notificationsEnabled', value);
    });
  }

  _updateLanguage(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = value;
      prefs.setString('selectedLanguage', value == 'العربية' ? 'ar' : 'en');
    });
    widget.changeLanguage(value == 'العربية' ? 'ar' : 'en');
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // الزر لتفعيل/إلغاء تفعيل الوضع المظلم
          SwitchListTile(
            title: Text(localization.darkMode),
            value: _isDarkMode,
            onChanged: (bool value) {
              _updateDarkMode(value); // تحديث حالة الوضع المظلم
            },
          ),
          SwitchListTile(
            title: Text(localization.notifications),
            value: _notificationsEnabled,
            onChanged: _updateNotifications,
          ),
          ListTile(
            title: Text(localization.switchLanguage),
            subtitle: Text(_selectedLanguage),
            onTap: () {
              _showLanguageDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('العربية'),
                onTap: () {
                  _updateLanguage('العربية');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('English'),
                onTap: () {
                  _updateLanguage('English');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

*/

// من نحن Page
class AboutUsPage extends StatelessWidget {
  final Function(String) changeLanguage;
  final VoidCallback toggleDarkMode;
  final bool isDarkMode;

  const AboutUsPage({
    super.key,
    required this.changeLanguage,
    required this.toggleDarkMode,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final textAlign = localization.locale.languageCode == 'ar'
        ? TextAlign.right
        : TextAlign.left;
    final alignment = localization.locale.languageCode == 'ar'
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(92, 64, 51, 1.0),
        elevation: 6,
        title: Text(
          localization.locale.languageCode == 'ar' ? 'من نحن' : 'About Us',
          style: const TextStyle(
            color: Color.fromARGB(255, 227, 227, 227),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: textAlign,
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset(
                'assets/Ab.jpg',
                height: 200,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              localization.locale.languageCode == 'ar' ? 'خُطـــــى' : 'Khutaa',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(218, 86, 60, 38),
              ),
              textAlign: textAlign,
            ),
            const SizedBox(height: 10),
            Text(
              localization.locale.languageCode == 'ar'
                  ? 'الإصدار 1.0.0'
                  : 'Version 1.0.0',
              textAlign: textAlign,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color.fromRGBO(92, 64, 51, 1.0),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      localization.locale.languageCode == 'ar'
                          ? 'من نحن'
                          : 'About Us',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 5, 5, 5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: alignment,
                    child: Text(
                      localization.locale.languageCode == 'ar'
                          ? 'نحن مجموعة من طالبات قسم علوم الحاسب الآلي بجامعة الطائف، قمنا بتطوير تطبيق "خُطى" ليكون بوابتك لاستكشاف تاريخ المملكة العربية السعودية وحاضرها. من خلال هذا التطبيق، نقدم لك رحلة مميزة لاستعراض محطات تاريخية هامة وتطورات حديثة، مع تسليط الضوء على مراحل تأسيس المملكة وتقدمها عبر الزمن. نتوجه بجزيل الشكر والتقدير للدكتورة بسمة الوسلاتي على دعمها المستمر وتوجيهاتها القيمة التي ساهمت بشكل كبير في إتمام هذا المشروع'
                          : 'We are a group of female students from the Computer Science Department at Taif University. We developed the "Khutaa" application to be your gateway to explore the history and present of the Kingdom of Saudi Arabia. Through this application, we offer you a unique journey to showcase important historical milestones and recent developments, highlighting the stages of the Kingdoms establishment and its progress over time. We extend our sincere thanks and appreciation to Dr. Basma Oueslati for her continuous support and valuable guidance that significantly contributed to the completion of this project.',
                      textAlign: textAlign,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color.fromRGBO(92, 64, 51, 1.0),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      localization.locale.languageCode == 'ar'
                          ? 'اتصل بنا'
                          : 'Contact Us',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.grey[600]),
                      const SizedBox(width: 10),
                      Align(
                        alignment: alignment,
                        child: Text(
                          'khutaa@gmail.com',
                          textAlign: textAlign,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.grey[600]),
                      const SizedBox(width: 10),
                      Align(
                        alignment: alignment,
                        child: Text(
                          '(+966) 123456789',
                          textAlign: textAlign,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color.fromRGBO(92, 64, 51, 1.0),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: alignment,
                    child: Text(
                      localization.locale.languageCode == 'ar'
                          ? 'مطورين التطبيق:  أريج ناشر العتيبي , سارة محمد السبيعي , مصباح عبد المحسن الشريف , نورة سلطان السبيعي , وله ناصر الدوسري '
                          : 'App Developers: Areej Nasher Al-Otaibi, Sarah Mohammed Al-Subaei, Misbah abdullmohsen alsharif, Norah sultan motlak Al-Subaei, wallah nasser aldosari',
                      textAlign: textAlign,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 11, 11, 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Drawer Widget
class AppDrawer extends StatelessWidget {
  final Function(String) changeLanguage;
  final VoidCallback toggleDarkMode; // إضافة toggleDarkMode
  final bool isDarkMode; // إضافة isDarkMode
  const AppDrawer({
    super.key,
    required this.changeLanguage,
    required this.toggleDarkMode, // تمرير toggleDarkMode
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context); // الحصول على الترجمة

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xff5C4033),
            ),
            child: Text(
                localization.locale.languageCode == 'ar' ? 'القائمة' : 'Menu',
                style: const TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.home), // أيقونة الرئيسية
            title: Text(
                localization.locale.languageCode == 'ar' ? 'الرئيسية' : 'Home'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          changeLanguage: changeLanguage,
                          toggleDarkMode:
                              toggleDarkMode, // تمرير toggleDarkMode
                          isDarkMode: isDarkMode, // تمرير isDarkMode
                        )),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.timeline), // أيقونة الخط الزمني
            title: Text(localization.locale.languageCode == 'ar'
                ? 'الخط الزمني'
                : 'Timeline'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TimelinePage(
                          changeLanguage: changeLanguage,
                          toggleDarkMode:
                              toggleDarkMode, // تمرير toggleDarkMode
                          isDarkMode: isDarkMode, // تمرير isDarkMode
                        )),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite), // أيقونة الإعجابات
            title: Text(localization.locale.languageCode == 'ar'
                ? 'الإعجابات'
                : 'Likes'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LikesPage(
                          changeLanguage: changeLanguage,
                          toggleDarkMode:
                              toggleDarkMode, // تمرير toggleDarkMode
                          isDarkMode: isDarkMode, // تمرير isDarkMode
                        )),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings), // أيقونة الإعدادات
            title: Text(localization.locale.languageCode == 'ar'
                ? 'الإعدادات'
                : 'Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsPage(
                          changeLanguage: changeLanguage,
                          toggleDarkMode:
                              toggleDarkMode, // تمرير toggleDarkMode
                          isDarkMode: isDarkMode, // تمرير isDarkMode
                        )),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info), // أيقونة من نحن
            title: Text(localization.locale.languageCode == 'ar'
                ? 'من نحن'
                : 'About Us'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AboutUsPage(
                          changeLanguage: changeLanguage,
                          toggleDarkMode:
                              toggleDarkMode, // تمرير toggleDarkMode
                          isDarkMode: isDarkMode, // تمرير isDarkMode
                        )),
              );
            },
          ),
        ],
      ),
    );
  }
}
