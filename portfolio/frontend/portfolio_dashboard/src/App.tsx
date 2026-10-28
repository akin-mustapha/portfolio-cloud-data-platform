// import { useState } from 'react'
import './App.css'
import { ChartPieInteractive } from './components/chart-pie-interactive'
import { ChartLineInteractive } from './components/chart-line-interactive'
import { ChartRadarDots } from './components/chart-radar-dots'

function App() {
  return (
    <>
      <section>
        <ChartLineInteractive />
        <ChartPieInteractive />
        <ChartRadarDots />
      </section>
    </>
  )
}

export default App
