// import { useState } from 'react'
import './App.css'
import { ChartPieInteractive } from './components/chart-pie-interactive'

function App() {
  return (
    <>
      <header>
        <h1 className="font-serif text-4xl" >Dashboard</h1>
      </header>
      <section>
        <ChartPieInteractive />
      </section>
    </>
  )
}

export default App
