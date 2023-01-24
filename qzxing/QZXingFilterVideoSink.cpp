#include "QZXingFilterVideoSink.h"
#include <QDebug>
#include <QtConcurrent/QtConcurrent>
#include "QZXingImageProvider.h"

QZXingFilter::QZXingFilter(QObject *parent)
    : QObject(parent)
    , decoder(QZXing::DecoderFormat_QR_CODE)
    , decoding(false)
{
    /// Connecting signals to handlers that will send signals to QML
    connect(&decoder, &QZXing::decodingStarted,
            this, &QZXingFilter::handleDecodingStarted);
    connect(&decoder, &QZXing::decodingFinished,
            this, &QZXingFilter::handleDecodingFinished);
}

QZXingFilter::~QZXingFilter()
{
    if(!processThread.isFinished()) {
        processThread.cancel();
        processThread.waitForFinished();
    }
}

void QZXingFilter::handleDecodingStarted()
{
    decoding = true;
    emit decodingStarted();
    emit isDecodingChanged();
}

void QZXingFilter::handleDecodingFinished(bool succeeded)
{
    decoding = false;
    emit decodingFinished(succeeded, decoder.getProcessTimeOfLastDecoding());
    emit isDecodingChanged();
}

void QZXingFilter::setOrientation(int orientation)
{
    if (orientation_ == orientation) {
        return;
    }

    orientation_ = orientation;
    emit orientationChanged(orientation_);
}

int QZXingFilter::orientation() const
{
    return orientation_;
}

void QZXingFilter::setVideoSink(QObject *videoSink){
    m_videoSink = qobject_cast<QVideoSink*>(videoSink);

    connect(m_videoSink, &QVideoSink::videoFrameChanged, this, &QZXingFilter::processFrame, Qt::DirectConnection);
}

void QZXingFilter::processFrame(const QVideoFrame &frame) {
    if(!m_decoding && (!m_elapsedTimer.isValid() || m_elapsedTimer.elapsed() >= 200)){
        m_elapsedTimer.restart();
        m_decoding = true;

        bool didWeMapTheFrame = false;
        if(!static_cast<QVideoFrame>(frame).isMapped()){

#ifdef Q_OS_ANDROID
//            m_videoSink->setRhi(nullptr); // https://bugreports.qt.io/browse/QTBUG-97789
            didWeMapTheFrame = static_cast<QVideoFrame>(frame).map(QVideoFrame::ReadOnly);
            //#else
            //    const QVideoFrame &f = frame;
#endif // Q_OS_ANDROID
//        }
//        if(static_cast<QVideoFrame>(frame).isMapped()){
//            QImage image = static_cast<QVideoFrame>(frame).toImage();
//            if(image.isNull())
//            {
//                qDebug() << "QZXingFilter error: Cant create image file to process.";
//                m_decoding = false;
//                return;
//            }
//            else {
//                processThread = QtConcurrent::run([=](){

//                    QThread::msleep(500);
//                    QImage frameToProcess(image);
//                    m_decoding = false;
//                    //                    const QRect& rect = captureRect.toRect();

//                    //                    if (captureRect.isValid() && frameToProcess.size() != rect.size()) {
//                    //                        frameToProcess = image.copy(rect);
//                    //                    }

//                    //                    if (!orientation_) {
//                    //                        decoder.decodeImage(frameToProcess);
//                    //                    } else {
//                    //                        QTransform transformation;
//                    //                        transformation.translate(frameToProcess.rect().center().x(), frameToProcess.rect().center().y());
//                    //                        transformation.rotate(-orientation_);

//                    //                        QImage translatedImage = frameToProcess.transformed(transformation);

//                    //                        decoder.decodeImage(translatedImage);
//                    //                    }

//                    //        static int i=0;
//                    //        qDebug() << "image.size()" << frameToProcess.size();
//                    //        qDebug() << "image.format()" << frameToProcess.format();
//                    //        const QString path = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) + "/qrtest/test_" + QString::number(i++ % 100) + ".png";
//                    //        qDebug() << "saving image" << i << "at:" << path << frameToProcess.save(path);

//                    //                    decoder.decodeImage(frameToProcess, frameToProcess.width(), frameToProcess.height());
//                });
//            }
//            if(didWeMapTheFrame) static_cast<QVideoFrame>(frame).unmap();
        } else {
            m_decoding = false;
        }

////#ifdef Q_OS_ANDROID
////        if(didWeMapTheFrame) f.unmap();
////#endif
    }
}
