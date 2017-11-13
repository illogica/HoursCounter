#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>
//#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QString locale = QLocale::system().name().left(2);
    QString translationPath = ":/i18n/translation_" + locale;

    QTranslator translator;

    if (translator.load(translationPath)) {
            app.installTranslator(&translator);
        } else {
            // Defaults to "en" translation
            // qDebug() << "Could not load translation";
        }

    app.setOrganizationName("Illogica");
    app.setOrganizationDomain("Illogicasoftware.com");
    app.setApplicationName("Hours counter application");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
