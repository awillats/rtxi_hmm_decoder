/*
 * Copyright (C) 2011 Georgia Institute of Technology, University of Utah,
 * Weill Cornell Medical College
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * This is a template implementation file for a user module derived from
 * DefaultGUIModel with a custom GUI.
 */

#include "hmm_decoder.h"
#include <iostream>
#include <main_window.h>

extern "C" Plugin::Object*
createRTXIPlugin(void)
{
  return new HmmDecoder();
}

static DefaultGUIModel::variable_t vars[] = {
  {
    "spike in", "?",
    DefaultGUIModel::INPUT,
  },
  {
    "dec out", "?",
    DefaultGUIModel::OUTPUT,
  },
  {
    "size out", "?",
    DefaultGUIModel::OUTPUT,
  },

  {
    "FR 1", "Firing rate",
    DefaultGUIModel::PARAMETER | DefaultGUIModel::DOUBLE,
  },
  {
    "FR 2", "Firing rate",
    DefaultGUIModel::PARAMETER | DefaultGUIModel::DOUBLE,
  },
  {
    "TR 1", "Transition rate",
    DefaultGUIModel::PARAMETER | DefaultGUIModel::DOUBLE,
  },
  {
    "TR 2", "Transition rate",
    DefaultGUIModel::PARAMETER | DefaultGUIModel::DOUBLE,
  },
  {
    "A State", "Tooltip description", DefaultGUIModel::STATE,
  },
};

static size_t num_vars = sizeof(vars) / sizeof(DefaultGUIModel::variable_t);

HmmDecoder::HmmDecoder(void)
  : DefaultGUIModel("HmmDecoder with Custom GUI", ::vars, ::num_vars)
{
  setWhatsThis("<p><b>HmmDecoder:</b><br>QWhatsThis description.</p>");
  DefaultGUIModel::createGUI(vars,
                             num_vars); // this is required to create the GUI
  customizeGUI();
  initParameters();
  update(INIT); // this is optional, you may place initialization code directly
                // into the constructor
  refresh();    // this is required to update the GUI with parameter and state
                // values
  QTimer::singleShot(0, this, SLOT(resizeMe()));
}

HmmDecoder::~HmmDecoder(void)
{
}

void
HmmDecoder::execute(void)
{
  //pull from input(0) into buffer
  //decode HMM state in existing buffer
  advanceSpkBuffer(input(0));

  output(0) = spike_buff.front();
  output(1) = spike_buff.back();
  output(2) = spike_buff.size();

  return;
}

void
HmmDecoder::initParameters(void)
{
  some_parameter = 0;
  some_state = 0;

  pfr1=30;
  pfr2=10;
  ptr1=0.1;
  ptr2=0.1;

  buffi = 0;
  bufflen = 100;
  
  // [BugFixed] I was tempted to use vector initialization code here, but it was overriding the scope of the vector!
  spike_buff.resize(bufflen,0);
  state_guess_buff.resize(bufflen,0);

  std::vector<double> vFr = {0.003, 0.02};
  std::vector<double> vTr = {0.03, 0.03};
  HMM bad_hmm = easyBuild(vFr,vTr,2,2);

}


//decl is fine, call is fine

HMM HmmDecoder::easyBuild(std::vector<double> vFr, std::vector<double> vTr, int nstates, int nemits)
{
    double A0[2] = {1-vTr[0], vTr[0]};
    double A1[2] = {vTr[1], 1-vTr[1]};
    double *A[2] = {A0, A1};
    
    double B0[2] = {1-vFr[0], vFr[0]};
    double B1[2] = {1-vFr[1], vFr[1]};
    double *B[2] = {B0, B1};

    //ideally this would be the transition probabilities...?
    double PI[2] = {.5,.5};

    HMM easy_hmm(2,2, A,B,PI);
    //HMM easy_hmm(10);
    return easy_hmm;
}


void HmmDecoder::advanceSpkBuffer(int newSpk)
{
  //cycle buffer left: http://en.cppreference.com/w/cpp/algorithm/rotate
  std::rotate(spike_buff.begin(), spike_buff.begin() + 1, spike_buff.end());
  spike_buff[bufflen-1]=newSpk;

  //spike_buff.push(newSpk); //adds to the end
  //spike_buff.pop();
}

/*
int* HmmDecoder::decodeHMM(int obs[], HMM guess_hmm)
{
  int* guessed = viterbi(guess_hmm, obs, bufflen);
  return guessed;  
}
*/
void HmmDecoder::decodeSpkBuffer()
{
    /*
    int* obs = spike_buff.data();

    int* guessed = decodeHMM(obs,guess_hmm);

    //NB: no idea why this temporary vector is necessary. should be able to replace this with one line...
    std::vector<int> temp_vec(guessed,guessed+bufflen);
    state_guess_buff = temp_vec;
    */
}


void
HmmDecoder::update(DefaultGUIModel::update_flags_t flag)
{
  int nnn;
  switch (flag) {
    case INIT:
      period = RT::System::getInstance()->getPeriod() * 1e-6; // ms

      setState("A State", some_state);

      setParameter("FR 1", pfr1);
      setParameter("FR 2", pfr2);
      setParameter("TR 1", ptr1);
      setParameter("TR 2", ptr2);

      break;

    case MODIFY:
      some_parameter = getParameter("GUI label").toDouble();

//Need to add the *period*1e3 in here;
     pfr1 = getParameter("FR 1").toDouble();
     pfr2 = getParameter("FR 2").toDouble();
     ptr1 = getParameter("TR 1").toDouble();
     ptr2 = getParameter("TR 2").toDouble();
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

void
HmmDecoder::customizeGUI(void)
{
  QGridLayout* customlayout = DefaultGUIModel::getLayout();

  QGroupBox* button_group = new QGroupBox;

  QPushButton* abutton = new QPushButton("Button A");
  QPushButton* bbutton = new QPushButton("Button B");
  QHBoxLayout* button_layout = new QHBoxLayout;
  button_group->setLayout(button_layout);
  button_layout->addWidget(abutton);
  button_layout->addWidget(bbutton);
  QObject::connect(abutton, SIGNAL(clicked()), this, SLOT(aBttn_event()));
  QObject::connect(bbutton, SIGNAL(clicked()), this, SLOT(bBttn_event()));

  customlayout->addWidget(button_group, 0, 0);
  setLayout(customlayout);
}

// functions designated as Qt slots are implemented as regular C++ functions
void
HmmDecoder::aBttn_event(void)
{
}

void
HmmDecoder::bBttn_event(void)
{
}
