// import { useState } from 'react'
import './App.css'
import { ChartPieInteractive } from './components/chart-pie-interactive'
// import { ChartLineInteractive } from './components/chart-line-interactive'
import { ChartRadarDots } from './components/chart-radar-dots'
import { AppSidebar } from "@/components/app-sidebar"
import { ChartBarMixed } from "@/components/chart-bar-mixed"
import { ChartAreaInteractive } from "@/components/chart-area-interactive"
// import { ChartRadialStacked } from "@/components/chart-radial-stacked"
import { SectionCards } from "@/components/section-card"
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from "@/components/ui/breadcrumb"
import { Separator } from "@/components/ui/separator"
import {
  SidebarInset,
  SidebarProvider,
  SidebarTrigger,
} from "@/components/ui/sidebar"
function App() {
  return (
    <>
    <SidebarProvider>
      <AppSidebar />
      <SidebarInset>
        <header className="flex h-16 shrink-0 items-center gap-2 border-b px-4">
          <SidebarTrigger className="-ml-1" />
          <Separator
            orientation="vertical"
            className="mr-2 data-[orientation=vertical]:h-4"
          />
          <Breadcrumb>
            <BreadcrumbList>
              <BreadcrumbItem className="hidden md:block">
                <BreadcrumbLink href="#">Build Your Application</BreadcrumbLink>
              </BreadcrumbItem>
              <BreadcrumbSeparator className="hidden md:block" />
              <BreadcrumbItem>
                <BreadcrumbPage>Data Fetching</BreadcrumbPage>
              </BreadcrumbItem>
            </BreadcrumbList>
          </Breadcrumb>
        </header>
        <div className="flex flex-1 flex-col gap-4 p-4">
          <div className="grid auto-rows-min gap-4 md:grid-cols-1">
            <SectionCards />
          </div>
          <ChartAreaInteractive />
            {/* <ChartLineInteractive /> */}
          {/* <div className="grid auto-rows-min gap-4 md:grid-cols-3">
            <ChartRadialStacked />
            <ChartRadialStacked />
            <ChartRadialStacked />
          </div> */}
          <div className="grid auto-rows-min gap-4 md:grid-cols-3">
            <ChartPieInteractive />
            <ChartPieInteractive />
            <ChartRadarDots />
          </div>
          <div className="grid auto-rows-min gap-4 md:grid-cols-2">
            <ChartBarMixed />
            <ChartBarMixed />
          </div>
        </div>
        <section>
        </section>
      </SidebarInset>
    </SidebarProvider>
    </>
  )
}

export default App
