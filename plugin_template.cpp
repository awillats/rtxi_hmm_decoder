/*
 * This is a template implementation file for a user module derived from
 * DefaultGUIModel with a custom GUI.
 */

#include <plugin_template.h>
#include <main_window.h>

#include <QLabel>
#include <QLayout>
#include <QPushButton>
#include <QTimer>
#include <QToolTip>
#include <QValidator>
#include <QWhatsThis>

#include <QGridLayout>
#include <QTableWidget>
#include <QButtonGroup>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QScrollArea>
#include <QGroupBox>

#include <QMdiSubWindow>

extern "C" Plugin::Object *
createRTXIPlugin(void)
{
  return new PluginTemplate();
}

static DefaultGUIModel::variable_t vars[] =
  {
    { "GUI label", "Tooltip description", DefaultGUIModel::PARAMETER
        | DefaultGUIModel::DOUBLE, },
    { "A State", "Tooltip description", DefaultGUIModel::STATE, }, };

static size_t num_vars = sizeof(vars) / sizeof(DefaultGUIModel::variable_t);

PluginTemplate::PluginTemplate(void) :
  DefaultGUIModel("PluginTemplate with Custom GUI", ::vars, ::num_vars)
{

//  QWhatsThis::add(this, "<p><b>PluginTemplate:</b><br>QWhatsThis description.</p>");

//  this->setWhatsThis(tr("<p><b>PluginTemplate:</b><br>QWhatsThis description.</p>"));
  createGUI(vars, num_vars); // this is required to create the GUI
  update( INIT); // this is optional, you may place initialization code directly into the constructor
  refresh(); // this is required to update the GUI with parameter and state values
}

PluginTemplate::~PluginTemplate(void)
{
}

void
PluginTemplate::execute(void)
{
  return;
}

void
PluginTemplate::update(DefaultGUIModel::update_flags_t flag)
{
  switch (flag)
    {
  case INIT:
    period = RT::System::getInstance()->getPeriod() * 1e-6; // ms
    setParameter("GUI label", some_parameter);
    setState("A State", some_state);
    break;
  case MODIFY:
    some_parameter = getParameter("GUI label").toDouble();
    break;
  case UNPAUSE:
    break;
  case PAUSE:
    break;
  case PERIOD:
    period = RT::System::getInstance()->getPeriod() * 1e-6; // ms
    break;
  default:
    break;

    }

}
/*
 * The following code is an example of how to overload the createGUI()
 * function to generate a custom GUI. Sections of this code are copied
 * from DefaultGUIModel.
 */

void
PluginTemplate::createGUI(DefaultGUIModel::variable_t *var, int size)
{

//  this->setFixedSize(200, 300); // Qt API for setting window size
 
/*  setAttribute(Qt::WA_DeleteOnClose);
  QMdiSubWindow *pluginWindow = new QMdiSubWindow;
  pluginWindow->setFixedSize(300,300);
  MainWindow::getInstance()->createMdi(pluginWindow);
*/

  //overall GUI layout with a "horizontal box" copied from DefaultGUIModel

  QBoxLayout *layout = new QVBoxLayout(this);
//  QBoxLayout *layout = new QVBoxLayout;

  QGroupBox *bttnGroup = new QGroupBox("Button Panel");
  QHBoxLayout *bttnGroupLayout = new QHBoxLayout;
  QPushButton *aBttn = new QPushButton("Button A");
  QPushButton *bBttn = new QPushButton("Button B");
  bttnGroupLayout->addWidget(aBttn);
  bttnGroupLayout->addWidget(bBttn);
  bttnGroup->setLayout(bttnGroupLayout);
  QObject::connect(aBttn, SIGNAL(clicked()), this, SLOT(aBttn_event()));
  QObject::connect(bBttn, SIGNAL(clicked()), this, SLOT(bBttn_event()));

  layout->addWidget(bttnGroup);

  QScrollArea *sv = new QScrollArea;
  sv->setWidgetResizable(true);
  layout->addWidget(sv);

  QWidget *viewport = new QWidget(sv->viewport());
  sv->setWidget(viewport);
  QGridLayout *scrollLayout = new QGridLayout(viewport);
  
  size_t nstate = 0, nparam = 0, nevent = 0, ncomment = 0;
  for (size_t i = 0; i < size; i++) {
	  if (var[i].flags & (PARAMETER | STATE | EVENT | COMMENT)) {
		  param_t param;

		  param.label = new QLabel(QString::fromStdString(var[i].name), viewport);
		  scrollLayout->addWidget(param.label, parameter.size(), 0);
		  param.edit = new DefaultGUILineEdit(viewport);
		  scrollLayout->addWidget(param.edit, parameter.size(), 1);

		  param.label->setToolTip(QString::fromStdString(var[i].description));
		  param.edit->setToolTip(QString::fromStdString(var[i].description));

		  if (var[i].flags & PARAMETER) {
			  if (var[i].flags & DOUBLE) {
				  param.edit->setValidator(new QDoubleValidator(param.edit));
				  param.type = PARAMETER | DOUBLE;
			  } else if (var[i].flags & UINTEGER) {
				  QIntValidator *validator = new QIntValidator(param.edit);
				  param.edit->setValidator(validator);
				  validator->setBottom(0);
				  param.type = PARAMETER | UINTEGER;
			  } else if (var[i].flags & INTEGER) {
				  param.edit->setValidator(new QIntValidator(param.edit));
				  param.type = PARAMETER | INTEGER;
			  } else 
			     param.type = PARAMETER;
			  param.index = nparam++;
			  param.str_value = new QString;
		  } else if (var[i].flags & STATE) { 
			  param.edit->setReadOnly(true);
			  palette.setBrush(param.edit->foregroundRole(), Qt::darkGray);
			  param.edit->setPalette(palette);
			  param.type = STATE;
			  param.index = nstate++;
		  } else if (var[i].flags & EVENT) {
			  param.edit->setReadOnly(true);
			  param.type = EVENT;
			  param.index = nevent++;
		  } else if (var[i].flags & COMMENT) {
			  param.type = COMMENT;
			  param.index = ncomment++;
		  }
		  parameter[QString::fromStdString(var[i].name)] = param;
	  }
  }

  QGroupBox *utilityBox = new QGroupBox;

  pauseButton = new QPushButton("Pause");
  pauseButton->setCheckable(true);
  QObject::connect(pauseButton, SIGNAL(toggled(bool)),this,SLOT(pause(bool)));
  modifyButton = new QPushButton("Modify");
  QObject::connect(modifyButton,SIGNAL(clicked(void)),this,SLOT(modify(void)));
  unloadButton = new QPushButton("Unload");
  QObject::connect(unloadButton,SIGNAL(clicked(void)),this,SLOT(exit(void)));
  QHBoxLayout *utilityBoxLayout = new QHBoxLayout;
  utilityBoxLayout->addWidget(pauseButton);
  utilityBoxLayout->addWidget(modifyButton);
  utilityBoxLayout->addWidget(unloadButton);
  utilityBox->setLayout(utilityBoxLayout);

  layout->addWidget(utilityBox);

//  pluginWindow->setWidget(this);
//  pluginWindow->setLayout(layout);
  show();

}

// functions designated as Qt slots are implemented as regular C++ functions
void
PluginTemplate::aBttn_event(void){

}

void
PluginTemplate::bBttn_event(void){

}
