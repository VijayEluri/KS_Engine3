void InitGrate() {
  //setup grate slopes
  m_grate_low = (GRATE_SHAKE_INIT-GRATE_SHAKE_CROSS)/grate_max_interval;
  m_grate_high = (GRATE_SHAKE_INIT-GRATE_SHAKE_CROSS)/grate_min_interval;
  m_grate_on = GRATE_SHAKE_CROSS/grate_on_interval;
}

void DoGrate() { // call once per second
  pRatioReactor = (float)Press[P_COMB]/(float)Press[P_REACTOR];
  if (pRatioReactor > pRatioReactorLevelBoundary[BAD][0] && pRatioReactor < pRatioReactorLevelBoundary[BAD][1]) {
    pRatioReactorLevel = BAD;
  }
  if (pRatioReactor > pRatioReactorLevelBoundary[GOOD][0] && pRatioReactor < pRatioReactorLevelBoundary[GOOD][1]) {
    pRatioReactorLevel = GOOD;
  }
  
  //set grate mode
  if (engine_state == ENGINE_ON || engine_state == ENGINE_STARTING || P_reactorLevel != OFF) {
    grateMode = GRATE_SHAKE_PRATIO;
  } else {
    grateMode = GRATE_SHAKE_OFF;
  }
  
  // if pressure ratio is "high" for a long time, shake harder
  if (pRatioReactorLevel == BAD && Press[P_REACTOR] < -50 && Press[P_COMB] < -50) {
    grate_pratio_accumulator++;
  } else {
    grate_pratio_accumulator -= 5;
  }
  grate_pratio_accumulator = max(0,grate_pratio_accumulator); // don't let it go below 0
  
  // handle different shaking modes
  switch (grateMode) {
  case GRATE_SHAKE_ON:
    analogWrite(FET_GRATE, 255);
    grate_motor_state = GRATE_MOTOR_LOW;
    break;
  case GRATE_SHAKE_OFF:
    analogWrite(FET_GRATE,0);
    grate_motor_state = GRATE_MOTOR_OFF;
    break;
  case GRATE_SHAKE_PRATIO:
    if (grate_val >= GRATE_SHAKE_CROSS) { // not time to shake
      if (pRatioReactorLevel == BAD) {
        grate_val -= m_grate_high;
      } else {
        grate_val -= m_grate_low;
      }
      grate_motor_state = GRATE_MOTOR_OFF;
      analogWrite(FET_GRATE,0);
    } else { //time to shake or reset
      if (grate_val >= 0) { //shake
        grate_val -= m_grate_on;
      } else { //reset
        grate_val = GRATE_SHAKE_INIT;
      }
      grate_motor_state = GRATE_MOTOR_LOW;
      analogWrite(FET_GRATE,255);
    }
    break;
  }
}
