import RevenueChart from '@/app/ui/dashboard/revenue-chart';
import LatestSongs from '@/app/ui/dashboard/latest-songs';
import { lusitana } from '@/app/ui/fonts';
import CardWrapper from '@/app/ui/dashboard/cards';
import { Suspense } from 'react';
import {
  RevenueChartSkeleton,
  LatestSongsSkeleton,
  CardsSkeleton,
} from '@/app/ui/skeletons';


export default async function Page() {
  return (
    <main>
      <h1 className={`${lusitana.className} mb-4 text-xl md:text-2xl`}>
        Dashboard
      </h1>
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <Suspense fallback={<CardsSkeleton />}>
          <CardWrapper type={'playlists'}/>
        </Suspense>
      </div>
      <div className="grid gap-6 mt-6 sm:grid-cols-2 lg:grid-cols-4">
        <Suspense fallback={<CardsSkeleton />}>
          <CardWrapper type={'albums'}/>
        </Suspense>
      </div>
      <div className="mt-6 grid grid-cols-1 gap-6 md:grid-cols-4 lg:grid-cols-8">
        <Suspense fallback={<LatestSongsSkeleton />}>
          <LatestSongs />
        </Suspense>
      </div>
    </main>
  );
}
